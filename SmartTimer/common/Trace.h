#ifndef TRACE_H
#define TRACE_H

#include <stdio.h>
#include <stdarg.h>

namespace Common
{
	class Trace
	{
	public:
		static void WriteFormat(const char *format, ...)
		{
			char message[MaxMessageLength];
			va_list ap;
			va_start(ap, format);
			vsprintf(message, format, ap);
			va_end(ap);

			WriteInner(message, false);
		}

		static void WriteFormatLine(const char *format, ...)
		{
			char message[MaxMessageLength];
			va_list ap;
			va_start(ap, format);
			vsprintf(message, format, ap);
			va_end(ap);

			WriteInner(message, true);
		}

		static void Write(const char *message, const char* category = NULL, bool showTime = true)
		{
			WriteInner(message, false, category, showTime);
		}

		static void WriteLine(const char *message, const char* category = NULL, bool showTime = true)
		{
			WriteInner(message, true, category, showTime);
		}

		static void enableLog()
		{
			EnableLog = true;
		}
		static void disableLog()
		{
			EnableLog = false;
		}

	private:
		static void WriteInner(const char* message, bool newLine = false, const char* category = NULL, bool showTime = true);

	public:
		const static char* System;			// "System"
		const static char* Information;		// "Information"
		const static char* Error;			// "Error"
		const static char* Warnning;		// "Warnning"

		const static int MaxMessageLength = 2048;

	private:
		friend class Debug;

		static bool EnableLog;
	};
}

#endif // TRACE_H
