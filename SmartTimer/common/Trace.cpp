#include "Trace.h"
#include "Convert.h"

namespace Common
{
	const char* Trace::System = "System";
	const char* Trace::Information = "Information";
	const char* Trace::Error = "Error";
	const char* Trace::Warnning= "Warnning";

	bool Trace::EnableLog = true;

	void Trace::WriteInner(const char* message, bool newLine, const char* category, bool showTime)
	{
		string str = "";
		if(showTime)
		{
			str.append(Convert::getCurrentTimeStr());
			str.append(" ");
		}
		if(category != NULL)
		{
			str.append(category);
			str.append(": ");
		}
		str.append(message);
		if(newLine)
		{
			str.append(Convert::NewLine);
		}

		const char* dstr = str.c_str();

		printf("%s", dstr);

		// Log to files.
//		if(EnableLog)
//		{
//			LogTraceListener* tl = Singleton<LogTraceListener>::instance();
//			if(tl != NULL)
//			{
//				tl->WriteLine(dstr, category);
//			}
//		}
	}
}
