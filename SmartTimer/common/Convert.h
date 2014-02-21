#ifndef CONVERT_H
#define CONVERT_H

#include <stdio.h>
#include <string>
#include "Vector.h"

using namespace std;

#ifndef byte
typedef unsigned char byte;
typedef unsigned short ushort;
#endif

namespace Common
{
	class Convert
	{
	public:
#if WIN32
		const static char* NewLine;
#else
		const static char* NewLine;
#endif
		const static char* Empty;

		static string getCurrentTimeStr();
		static string getDateTimeStr(const time_t timep, bool includems = false);
		static bool getDateTimeStr(const time_t timep, char* str, bool includems = false);
		static time_t parseDateTime(const string& timeStr, bool fullFormat = true);
		static bool isDateTime(const string& timeStr);
		static bool isDateTime(const char* timeStr);
		static time_t parseDateTime(const char* timeStr, bool fullFormat = true);
		static string getTimeStr(const time_t timep, bool includeSec = false);
		static string getTimeHMSStr(const time_t timep);
		static string getTimeHMStr(const time_t timep);
		static string getTimeMSStr(const time_t timep);

		static time_t parseDate(const string& dateStr);
		static string getDateStr(const time_t timep);

		static void replaceStr(string& strBig, const string& strsrc, const string& strdst);

		static string convertStr(const char *format, ...);

		static string convertStr(int value);
		static string convertStr(uint value);

		static string convertStr(float value, int pointSize = -1);
		static bool convertStr(float value, char* str, int pointSize = -1);

		static string convertStr(double value, int pointSize = -1);

		static bool parseInt32(const string& text, int& value);
		static bool parseUInt32(const string& text, uint& value);

		static bool parseInt16(const string& text, short& value);
		static bool parseUInt16(const string& text, ushort& value);

		static bool parseByte(const string& text, byte& value);

		static bool parseSingle(const string& text, float& value);
		static bool parseDouble(const string& text, double& value);

		static string convertIPStr(byte ip1, byte ip2, byte ip3, byte ip4);
        static string convertIPStr(const string& ip1, const string& ip2, const string& ip3, const string& ip4);
        
		static bool parseIPStr(const string& text, string& ip1, string& ip2, string& ip3, string& ip4);

		static void splitStr(const string& text, const char splitSymbol, Vector<string>& texts);

		static uint convertIpValue(const string& ipStr);

	public:
		static const int MaxFormatStrLength = 2048;
	};
}

#endif // CONVERT_H