#ifndef DEBUG_H
#define DEBUG_H

#include "Convert.h"
#include "Trace.h"
#include "assert.h"

namespace Common
{
	class Debug
	{
	public:
		static void Assert(bool condition)
		{
#ifdef DEBUG
			assert(condition);
#endif
		}
		static void WriteFormat(const char *format, ...)
		{
#ifdef DEBUG
			char message[Trace::MaxMessageLength];
			va_list ap;
			va_start(ap, format);
			vsprintf(message, format, ap);
			va_end(ap);

			WriteInner(message, false);
#endif
		}

		static void WriteFormatLine(const char *format, ...)
		{
#ifdef DEBUG
			char message[Trace::MaxMessageLength];
			va_list ap;
			va_start(ap, format);
			vsprintf(message, format, ap);
			va_end(ap);

			WriteInner(message, true);
#endif
		}

		static void Write(const char *message, const char* category = NULL, bool showTime = true)
		{
#ifdef DEBUG
			WriteInner(message, false, category, showTime);
#endif
		}

		static void WriteLine(const char *message, const char* category = NULL, bool showTime = true)
		{
#ifdef DEBUG
			WriteInner(message, true, category, showTime);
#endif
		}

	private:
		static void WriteInner(const char* message, bool newLine = false, const char* category = NULL, bool showTime = true)
		{
#ifdef DEBUG
			Trace::WriteInner(message, newLine, category, showTime);
#endif
		}
	};
}

#endif // DEBUG_H
