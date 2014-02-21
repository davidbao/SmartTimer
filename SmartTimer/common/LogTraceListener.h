#ifndef LOGTRACELISTENER_H
#define LOGTRACELISTENER_H

#include <string>
#include <qobject.h>
#include <qdir.h>
#include <qfile.h>
#include <qdatetime.h>
#include "Singleton.h"
#include "ThreadCreator.h"

using namespace std;

namespace Common
{
	enum LogLevel
	{
		/// <summary>
		/// Output error-handling messages.
		/// </summary>
		LogError,
		/// <summary>
		/// Output informational messages, warnings, and error-handling messages.
		/// </summary>
		LogInfo,
		/// <summary>
		/// Output no tracing and debugging messages.
		/// </summary>
		LogOff,
		/// <summary>
		/// Output all debugging and tracing messages.
		/// </summary>
		LogVerbose,
		/// <summary>
		/// Output warnings and error-handling messages.
		/// </summary>
		LogWarning,
		/// <summary>
		/// Output system message.
		/// </summary>
		LogSystem,
	};

	class LogTraceListener
	{
	public:
		LogTraceListener(const char* prefix = NULL, const char* suffix = NULL, const char* logPath = "logs");
		~LogTraceListener();

		void WriteLine(const char* message, const char* category);

	private:
		void createFile(const char* logPath);
		void createFile(const QDateTime& time);
		void createFile(const QDateTime& time, const char* logPath);

		void deleteUnuseFiles();
		void deleteFiles(int days = 30);
		void deleteFiles(const QDateTime& time);

		void updateMessageCount(const char* category = NULL);
		void flushInner(bool locked = true);

		bool isDiskFull();
		void removeFile(QDir& dir, const string& fileName, int days);

		DECLARE_SINGLETON_CLASS(LogTraceListener);

	protected:
		friend void processProc(void* parameter);
		void processProcInner();
		friend void deleteUnuseFilesAction(void* parameter);

	private:
		string _prefix;
		string _suffix;
		string _logPath;
		string _fullFileName;

		QFile* _file;

		int _messageCount;
		const static int MaxMessageCount = 10;

		string _message;
		QMutex _messageMutex;

		int _reservationDays;
		bool _diskIsFull;

		ThreadCreator* _processThread;
	};
}

#endif // LOGTRACELISTENER_H