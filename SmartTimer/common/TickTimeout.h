#ifndef TICKTIMEOUT_H
#define TICKTIMEOUT_H

#include <stdio.h>
#include <time.h>
#include <sys/time.h>
#include "Thread.h"

namespace Common
{
	typedef bool (*delay_callback)(void*);

	class TickTimeout
	{
	public:
		static inline bool IsTimeout(uint start, uint end, uint now)
		{
			if (end == start) return true;
			if (end > start)
			{
				return now > end || now < start;
			}
			return now > end && now < start;
		}

		static inline bool IsTimeout(uint start, uint end)
		{
			return IsTimeout(start, end, GetCurrentTickCount());
		}

		static inline uint GetDeadTickCount(int timeout)
		{
			return GetDeadTickCount(GetCurrentTickCount(), timeout);
		}

		static inline uint GetDeadTickCount(uint start, int timeout)
		{
			return (uint)(start + timeout);
		}

		static inline uint Elapsed(uint start, uint end)
		{
			return (end >= start) ? end - start : 0xFFFFFFFF - end + start;
		}

		static inline uint GetCurrentTickCount()
		{
#if WIN32
			return GetTickCount();
#else
			return mono_msec_ticks();
			//struct timespec ts;
			//clock_gettime(CLOCK_MONOTONIC, &ts);
			//return (ts.tv_sec * 1000 + ts.tv_nsec / 1000000);
#endif
		}

		static void sdelay(time_t sec = 10, delay_callback condition = NULL, void* parameter = NULL)
		{
			msdelay(sec * 1000, condition, parameter);
		}
		static void msdelay(time_t msec = 3000, delay_callback condition = NULL, void* parameter = NULL)
        {
            uint startTime = GetCurrentTickCount();
            uint deadTime = GetDeadTickCount(startTime, msec);

            do
            {
                if (condition != NULL && condition(parameter))
                {
                    break;
                }

                if (IsTimeout(startTime, deadTime, GetCurrentTickCount()))
                {
                    break;
                }

                Thread::msleep(1);
            } while (true);
        }

	private:
#if !WIN32
#define MTICKS_PER_SEC 10000000

		/* Returns the number of 100ns ticks from unspecified time: this should be monotonic */
		static inline int64_t mono_100ns_ticks ()
		{
			struct timeval tv;
			if (gettimeofday (&tv, NULL) == 0)
				return ((int64_t)tv.tv_sec * 1000000 + tv.tv_usec) * 10;
			return 0;
		}

		static inline int64_t get_boot_time ()
		{
			FILE *uptime = fopen ("/proc/uptime", "r");
			if (uptime) {
				double upt;
				if (fscanf (uptime, "%lf", &upt) == 1) {
					int64_t now = mono_100ns_ticks ();
					fclose (uptime);
					return now - (int64_t)(upt * MTICKS_PER_SEC);
				}
				fclose (uptime);
			}
			/* a made up uptime of 300 seconds */
			return (int64_t)300 * MTICKS_PER_SEC;
		}

		/* Returns the number of milliseconds from boot time: this should be monotonic */
		static inline uint mono_msec_ticks ()
		{
			static int64_t boot_time = 0;
			int64_t now;
			if (!boot_time)
				boot_time = get_boot_time ();
			now = mono_100ns_ticks ();
			//printf ("now: %llu (boot: %llu) ticks: %llu\n", (int64_t)now, (int64_t)boot_time, (int64_t)(now - boot_time));
			return (uint)(now - boot_time)/10000;
		}
#endif
	};
}
#endif // TICKTIMEOUT_H