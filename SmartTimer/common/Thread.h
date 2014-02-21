#ifndef THREAD_H
#define THREAD_H

#if WIN32
#include <Windows.h>
#else
#include <unistd.h>
#endif
#include "Convert.h"

class Thread
{
public:
	static void msleep(uint msecs)
	{
#if WIN32
		Sleep(msecs);
#else
		usleep(msecs * 1000);
#endif
	}
};

#endif // THREAD_H