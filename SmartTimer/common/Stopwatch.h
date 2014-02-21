#ifndef STOPWATCH_H
#define STOPWATCH_H

#if DEBUG
#include "Convert.h"
#include "TickTimeout.h"
#include "Debug.h"
#include "Trace.h"

namespace Common
{
	class Stopwatch
	{
	public:
		Stopwatch(const string& info, time_t deadTime = 0) : _info(info)
		{
			start(deadTime);
		}
		~Stopwatch()
		{
			stop();
		}

		inline void start(time_t deadTime = 0)
		{
			_deadTime = deadTime;
			_startTime = TickTimeout::GetCurrentTickCount();
		}
		inline void stop()
		{
			_endTime = TickTimeout::GetCurrentTickCount();
			uint elasped = TickTimeout::Elapsed(_startTime, _endTime);
			if(elasped >= _deadTime)
			{
				if(elasped <= 10 * 1000)	// less than 10 seconds
				{
					Debug::WriteFormatLine("%s: Elapsed: %d ms", _info.c_str(), elasped);
				}
				else
				{
					Debug::WriteFormatLine("%s: Elapsed: %.3f s", _info.c_str(), elasped / 1000.0f);
				}
			}
		}
		inline void setInfo(const string& info)
		{
			_info = info;
		}

	private:
		string _info;
		time_t _deadTime;
		time_t _startTime;
		time_t _endTime;
	};
}
#endif // DEBUG
#endif // STOPWATCH_H