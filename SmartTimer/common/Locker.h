#ifndef LOCKER_H
#define LOCKER_H

#include "mutex"

using namespace std;

namespace Common
{
	class Locker
	{
	public:
		Locker(mutex* mutexp) : _mutex(NULL)
		{
			if(mutexp != NULL)
			{
				_mutex = mutexp;
				_mutex->lock();
			}
		}
		~Locker()
		{
			if(_mutex != NULL)
			{
				_mutex->unlock();
				_mutex = NULL;
			}
		}

	private:
		mutex* _mutex;
	};
}

#endif // LOCKER_H