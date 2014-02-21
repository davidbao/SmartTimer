#include <stdio.h>
#include <qtimer.h>
#include <qfile.h>
#include <qdir.h>
#include <qiodevice.h>
#if WIN32
#include <Windows.h>
#else
#include <sys/vfs.h>
#endif
#include "LogTraceListener.h"
#include "QApplicationExt.h"
#include "Debug.h"
#include "Convert.h"
#include "DiskChecker.h"
#include "../Resources.h"

namespace Common
{
	void processProc(void* parameter)
	{
		LogTraceListener* listener = (LogTraceListener*)parameter;
		ASSERT(listener);
		listener->processProcInner();
	}
	void deleteUnuseFilesAction(void* parameter)
	{
		LogTraceListener* listener = (LogTraceListener*)parameter;
		ASSERT(listener);
		listener->deleteUnuseFiles();
	}

	LogTraceListener::LogTraceListener(const char* prefix, const char* suffix, const char* logPath)
	{
		_reservationDays = 30;	// 30 days
		_messageCount = 0;
		_diskIsFull = false;
		_fullFileName = "";
		_message = "";
		if(prefix != NULL)
			_prefix = prefix;
		else
			_prefix = "";

		if(suffix != NULL)
			_suffix = suffix;
		else
			_suffix = "";

		QApplicationExt* app = QApplicationExt::instance();
		string path = app->applicationDirPath();
		_logPath = path + "/" + logPath + "/";

		createFile(_logPath.c_str());

		_processThread = new ThreadCreator();
#if _DEBUG
		_processThread->setName("LogTraceListenerProc");
#endif
		time_t interval = 60 * 1000;		// 60 seconds.
		_processThread->startProc(processProc, this, interval, deleteUnuseFilesAction, this);
	}

	LogTraceListener::~LogTraceListener()
	{
		if(_processThread != NULL)
		{
			_processThread->stop();
			delete _processThread;
			_processThread = NULL;
		}

		flushInner();
		_file->close();
		delete _file;
		_file = NULL;
	}

	void LogTraceListener::WriteLine(const char* message, const char* category)
	{
		Locker locker(&_messageMutex);

		if(message == NULL || strlen(message) == 0)
			return;

		if(_diskIsFull)
			return;

		_message.append(message);

		updateMessageCount(category);
	}

	void LogTraceListener::updateMessageCount(const char* category)
	{
		_messageCount++;

		if (stricmp(category, Trace::Error) == 0 ||
			stricmp(category, Trace::System) == 0)
		{
			flushInner(false);
		}
		else
		{
			if (_messageCount >= MaxMessageCount)
			{
				flushInner(false);
			}
		}
	}

	void LogTraceListener::flushInner(bool locked)
	{
		if(locked)
		{
			_messageMutex.lock();
		}

		if (_messageCount > 0)
		{
			_messageCount = 0;

			int length = _message.length();
			_file->writeBlock(_message.c_str(), length);
			_file->flush();
			_message = "";
		}

		if(locked)
		{
			_messageMutex.unlock();
		}
	}

	bool LogTraceListener::isDiskFull()
	{
		const int MaxSize = 10 * 1024 * 1024;    // 10 M;
		return DiskChecker::isDiskFull(_logPath, MaxSize);
	}

	void LogTraceListener::processProcInner()
	{
		QDateTime now = QDateTime::currentDateTime();
		// Try to create new log file.
		createFile(now);

		// Try to delete some log files at 1 AM.
		deleteFiles(now);

		flushInner();

		_diskIsFull = isDiskFull();
	}

	void LogTraceListener::deleteUnuseFiles()
	{
		deleteFiles(_reservationDays);
	}

	void LogTraceListener::deleteFiles(const QDateTime& time)
	{
		if (time.time().hour() == 1 && time.time().minute() == 0)
		{
			deleteUnuseFiles();
		}
	}

	void LogTraceListener::deleteFiles(int days)
	{
		if(qApp == NULL)
			return;

		QDir dir(qApp->tr(_logPath.c_str()));
		if(dir.exists())
		{
			string filter = "*.log";

#if WIN32
			WIN32_FIND_DATA ffd;
			HANDLE hFind = INVALID_HANDLE_VALUE;
			// Find the first file in the directory.
			hFind = FindFirstFile((_logPath + "/" + filter).c_str(), &ffd);
			if (INVALID_HANDLE_VALUE != hFind) 
			{
				// List all the files in the directory with some info about them.
				do
				{
					if (ffd.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY)
					{
					}
					else
					{
						removeFile(dir, ffd.cFileName, days);
					}
				}
				while (FindNextFile(hFind, &ffd) != 0);
				FindClose(hFind);
			}
#else
			dir.setNameFilter(filter.c_str());
			QFileInfoList* list = (QFileInfoList*)dir.entryInfoList();
			if(list != NULL)
			{
				QFileInfo *fi;
				for ( fi=list->first(); fi != 0; fi=list->next() )
				{
					removeFile(dir, Convert::convertStr(fi->fileName()), days);
				}
			}
#endif
		}
	}

	void LogTraceListener::removeFile(QDir& dir, const string& fileName, int days)
	{
		string name = fileName;
		if (strcmp(_fullFileName.c_str(), name.c_str()) != 0)
		{
			const QDateTime now = QDateTime::currentDateTime();

			if (!_prefix.empty())
			{
				Convert::replaceStr(name, _prefix, "");
			}
			if (!_suffix.empty())
			{
				Convert::replaceStr(name, _suffix, "");
			}
			Convert::replaceStr(name, ".log", "");
			QDate date = Convert::parseDate(name);
			int sec = now.secsTo(date);
			if (!date.isNull() && date.isValid() &&
				sec < 0 && (-sec > days * 24 * 3600))
			{
				bool result = dir.remove(fileName.c_str());
				if(result)
				{
					Trace::WriteFormatLine(Resources::RemoveLogFilesSuccessfullyStr, fileName.c_str());
				}
				else
				{
					Trace::WriteFormatLine(Resources::FailedtoRemoveLogFilesStr, fileName.c_str());
				}
			}
		}
	}

	void LogTraceListener::createFile(const QDateTime& time)
	{
		if (time.time().hour() == 0 && time.time().minute() == 0)
		{
			_file->close();
			delete _file;
			_file = NULL;
			createFile(_logPath.c_str());
		}
	}

	void LogTraceListener::createFile(const char* logPath)
	{
		createFile(QDateTime::currentDateTime(), logPath);
	}

	void LogTraceListener::createFile(const QDateTime& time, const char* logPath)
	{
		char fileName[256];
		sprintf(fileName, "%s%s%s.log", _prefix.c_str(), Convert::getDateStr(time.date()).c_str(), _suffix.c_str());

		bool result;
		QDir dir(qApp->tr(logPath));
		if(!dir.exists())
		{
			result = dir.mkdir(_fullFileName.c_str());
			Debug::Assert(result);
		}
		_fullFileName = string(logPath) + "/" + fileName;
		_file = new QFile(qApp->tr(_fullFileName.c_str()));
		result = _file->open(IO_ReadWrite | IO_Append);
		Debug::Assert(result);
	}
}
