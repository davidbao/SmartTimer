#include "Convert.h"
#include <stdarg.h>
#include <sys/time.h>
#include <time.h>

namespace Common
{
#if WIN32
	const char* Convert::NewLine = "\r\n";
#else
	const char* Convert::NewLine = "\n";
#endif
	const char* Convert::Empty = "";

	string Convert::getDateTimeStr(const time_t timep, bool includems)
	{
		if(timep > 0)
		{
			char temp[64];
            struct tm* tmp = localtime(&timep);
			if(!includems)
			{
				sprintf(temp, "%04d-%02d-%02d %02d:%02d:%02d", tmp->tm_year + 1900, tmp->tm_mon + 1, tmp->tm_mday,
					tmp->tm_hour, tmp->tm_min, tmp->tm_sec);
			}
			else
			{
                // todo: show the millitm.
				sprintf(temp, "%04d-%02d-%02d %02d:%02d:%02d.%03d", tmp->tm_year + 1900, tmp->tm_mon + 1, tmp->tm_mday,
                        tmp->tm_hour, tmp->tm_min, tmp->tm_sec, 0);
			}
			return temp;
		}
		return "";
	}
	bool Convert::getDateTimeStr(const time_t timep, char* str, bool includems)
	{
		string result = getDateTimeStr(timep, includems);
        if(result != "")
        {
            strcpy(str, result.c_str());
            return true;
        }
        else
        {
            return false;
        }
	}
	string Convert::getTimeStr(const time_t timep, bool includeSec)
	{
		if(timep > 0)
		{
			char temp[16];
            struct tm* tmp = localtime(&timep);
			if(!includeSec)
			{
				sprintf(temp, "%02d:%02d", tmp->tm_hour, tmp->tm_min);
			}
			else
			{
				sprintf(temp, "%02d:%02d:%02d", tmp->tm_hour, tmp->tm_min, tmp->tm_sec);
			}
			return temp;
		}
		return "";
	}
	string Convert::getTimeHMSStr(const time_t timep)
	{
		if(timep > 0)
		{
			char temp[16];
            struct tm* tmp = localtime(&timep);
			sprintf(temp, "%02d:%02d:%02d", tmp->tm_hour, tmp->tm_min, tmp->tm_sec);
			return temp;
		}
		return "00:00";
	}
	string Convert::getTimeHMStr(const time_t timep)
	{
		if(timep > 0)
		{
			char temp[16];
            struct tm* tmp = localtime(&timep);
			sprintf(temp, "%02d:%02d", tmp->tm_hour, tmp->tm_min);
			return temp;
		}
		return "00:00";
	}
	string Convert::getTimeMSStr(const time_t timep)
	{
		if(timep > 0)
		{
			char temp[16];
            struct tm* tmp = localtime(&timep);
			sprintf(temp, "%02d:%02d", tmp->tm_min, tmp->tm_sec);
			return temp;
		}
		return "00:00";
	}

	string Convert::getCurrentTimeStr()
	{
        time_t now = time(NULL);
		return getDateTimeStr(now);
	}
	time_t Convert::parseDateTime(const string& timeStr, bool fullFormat)
	{
        bool success = false;
		int year, month, day, hour, minute, second;
		if(fullFormat)
		{
			int result = sscanf(timeStr.c_str(), "%04d-%02d-%02d %02d:%02d:%02d", &year, &month, &day, &hour, &minute, &second);
			if(result == 6)
			{
				success = true;
			}
		}
		else
		{
			int result = sscanf(timeStr.c_str(), "%d-%d-%d %d:%d:%d", &year, &month, &day, &hour, &minute, &second);
			if(result == 6)
			{
				success = true;
			}
		}
        if(success)
        {
            struct tm tmp;
            memset(&tmp, 0, sizeof(tmp));
            tmp.tm_year = year - 1900;
            tmp.tm_mon = month;
            tmp.tm_mday = day;
            tmp.tm_hour = hour;
            tmp.tm_min = minute;
            tmp.tm_sec = second;
            return mktime(&tmp);
        }
		return 0;
	}
	time_t Convert::parseDateTime(const char* timeStr, bool fullFormat)
	{
		return parseDateTime(string(timeStr), fullFormat);
	}
	bool Convert::isDateTime(const string& timeStr)
	{
		int year, month, day, hour, minute, second;
		int result = sscanf(timeStr.c_str(), "%d-%d-%d %d:%d:%d", &year, &month, &day, &hour, &minute, &second);
		if(result == 6)
		{
			if(!(year >= 0 && year <= 9999))
				return false;
            
            struct tm tmp;
            memset(&tmp, 0, sizeof(tmp));
            tmp.tm_year = year - 1900;
            tmp.tm_mon = month;
            tmp.tm_mday = day;
            tmp.tm_hour = hour;
            tmp.tm_min = minute;
            tmp.tm_sec = second;
            return mktime(&tmp) > 0;
		}
		return false;
	}
	bool Convert::isDateTime(const char* timeStr)
	{
		return isDateTime(string(timeStr));
	}

	time_t Convert::parseDate(const string& dateStr)
	{
		int year, month, day;
		int result = sscanf(dateStr.c_str(), "%04d-%02d-%02d", &year, &month, &day);
		if(result == 3)
		{
            struct tm tmp;
            memset(&tmp, 0, sizeof(tmp));
            tmp.tm_year = year - 1900;
            tmp.tm_mon = month;
            tmp.tm_mday = day;
            tmp.tm_hour = 0;
            tmp.tm_min = 0;
            tmp.tm_sec = 0;
            return mktime(&tmp);
		}
		return 0;
	}

	string Convert::getDateStr(const time_t timep)
	{
		if(timep > 0)
		{
			char temp[32];
            struct tm* tmp = localtime(&timep);
			sprintf(temp, "%04d-%02d-%02d", tmp->tm_year + 1900, tmp->tm_mon + 1, tmp->tm_mday);
			return temp;
		}
		return "";
	}

	void Convert::replaceStr(string& strBig, const string& strsrc, const string& strdst)
	{
		std::string::size_type pos = 0;
		while( (pos = strBig.find(strsrc, pos)) != string::npos)
		{
			strBig.replace(pos, strsrc.length(), strdst);
			pos += strdst.length();
		}
	}

	string Convert::convertStr(const char *format, ...)
	{
		char message[MaxFormatStrLength];
		va_list ap;
		va_start(ap, format);
		vsprintf(message, format, ap);
		va_end(ap);
		return message;
	}
	string Convert::convertStr(int value)
	{
		char temp[32];
		sprintf(temp, "%d", value);
		return temp;
	}
	string Convert::convertStr(uint value)
	{
		char temp[32];
		sprintf(temp, "%d", value);
		return temp;
	}
	string Convert::convertStr(float value, int pointSize)
	{
		char temp[32];
		if(pointSize >=0 && pointSize <= 6)
		{
			sprintf(temp, "%.*f", pointSize, value);
		}
		else
		{
			sprintf(temp, "%f", value);
		}
		return temp;
	}
	bool Convert::convertStr(float value, char* str, int pointSize)
	{
		char temp[32];
		if(pointSize >=0 && pointSize <= 6)
		{
			sprintf(temp, "%.*f", pointSize, value);
		}
		else
		{
			sprintf(temp, "%f", value);
		}
		strcpy(str, temp);
		return true;
	}
	string Convert::convertStr(double value, int pointSize)
	{
		char temp[32];
		if(pointSize >=0 && pointSize <= 15)
		{
			sprintf(temp, "%.*lf", pointSize, value);
		}
		else
		{
			sprintf(temp, "%lf", value);
		}
		return temp;
	}

	bool Convert::parseInt32(const string& text, int& value)
	{
		int len = 0;
		if(sscanf(text.c_str(), "%d%n", &value, &len) == 1 && text.length() == len)
		{
			return true;
		}
		return false;
	}
	bool Convert::parseUInt32(const string& text, uint& value)
	{
		int len = 0;
		if(sscanf(text.c_str(), "%d%n", &value, &len) == 1 && text.length() == len)
		{
			return true;
		}
		return false;
	}

	bool Convert::parseInt16(const string& text, short& value)
	{
		int len = 0;
		if(sscanf(text.c_str(), "%hd%n", &value, &len) == 1 && text.length() == len)
		{
			return true;
		}
		return false;
	}
	bool Convert::parseUInt16(const string& text, ushort& value)
	{
		int len = 0;
		if(sscanf(text.c_str(), "%hd%n", &value, &len) == 1 && text.length() == len)
		{
			return true;
		}
		return false;
	}
	bool Convert::parseByte(const string& text, byte& value)
	{
		ushort uValue;
		if(parseUInt16(text, uValue) && uValue <= 255)
		{
			value = (byte)uValue;
			return true;
		}
		return false;
	}
	bool Convert::parseSingle(const string& text, float& value)
	{
		int len = 0;
		if(sscanf(text.c_str(), "%f%n", &value, &len) == 1 && text.length() == len)
		{
			return true;
		}
		return false;
	}
	bool Convert::parseDouble(const string& text, double& value)
	{
		int len = 0;
		if(sscanf(text.c_str(), "%lf%n", &value, &len) == 1 && text.length() == len)
		{
			return true;
		}
		return false;
	}

	string Convert::convertIPStr(byte ip1, byte ip2, byte ip3, byte ip4)
	{
		char temp[32];
		sprintf(temp, "%d.%d.%d.%d", ip1, ip2, ip3, ip4);
		return temp;
	}
	string Convert::convertIPStr(const string& ip1, const string& ip2, const string& ip3, const string& ip4)
	{
		int i1, i2, i3, i4;
		if(Convert::parseInt32(ip1, i1) && (i1>=0 && i1<=255) &&
			Convert::parseInt32(ip2, i2) && (i2>=0 && i2<=255) &&
			Convert::parseInt32(ip3, i3) && (i3>=0 && i3<=255) &&
			Convert::parseInt32(ip4, i4) && (i4>=0 && i4<=255))
		{
			return convertIPStr(i1, i2, i3, i4);
		}
		return "";
	}
	bool Convert::parseIPStr(const string& str, string& ip1, string& ip2, string& ip3, string& ip4)
	{
		uint nip1 = 0;
		uint nip2 = 0;
		uint nip3 = 0;
		uint nip4 = 0;
		if(sscanf(str.c_str(), "%d.%d.%d.%d", &nip1, &nip2, &nip3, &nip4) == 4)
		{
			ip1 = Convert::convertStr(nip1).c_str();
			ip2 = Convert::convertStr(nip2).c_str();
			ip3 = Convert::convertStr(nip3).c_str();
			ip4 = Convert::convertStr(nip4).c_str();
			return true;
		}
		return false;
	}

	void Convert::splitStr(const string& str, const char splitSymbol, Vector<string>& texts)
	{
		int size;
		string* splitStr = NULL;
		string text = str;

		while(!text.empty())
		{
			size = text.find(splitSymbol);
			if(size < 0)
			{
				splitStr = new string(text);
				texts.add(splitStr);
				return;
			}
			splitStr = new string(text.substr(0, size));
			texts.add(splitStr);
			if(*splitStr != text)
			{
				text = text.substr(size + 1, text.length() - size);
			}
		}
	}

	uint Convert::convertIpValue(const string& ipStr)
	{
		uint ip1 = 0;
		uint ip2 = 0;
		uint ip3 = 0;
		uint ip4 = 0;
		if(sscanf(ipStr.c_str(), "%d.%d.%d.%d", &ip1, &ip2, &ip3, &ip4) == 4)
		{
			return (ip1<<24)
				|(ip2<<16)
				|(ip3<<8)
				|ip4;
		}
		return 0;
	}
}
