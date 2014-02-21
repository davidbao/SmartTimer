#ifndef SINGLETON_H
#define SINGLETON_H

#include <stdio.h>
#include <memory>
using namespace std;

#include <mutex>
#include "Locker.h"

using namespace std;

namespace Common
{
	template <class T>
	class Singleton
	{
	public:
		static inline T* instance();

		static inline void initialize()
		{
			Singleton<T>::instance();
		}
		static inline void unInitialize()
		{
			delete Singleton<T>::instance();
			Singleton<T>::_instance = NULL;
		}

	private:
		Singleton(void){}
		~Singleton(void){}
		Singleton(const Singleton&){}
		Singleton & operator= (const Singleton &){}

		static T* _instance;
		static mutex _instanceMutex;
	};

	template <class T>
	T* Singleton<T>::_instance;
	template <class T>
	mutex Singleton<T>::_instanceMutex;

	template <class T>
	inline T* Singleton<T>::instance()
	{
		Locker locker(&_instanceMutex);

		if(NULL == _instance)
		{
			_instance = new T;
		}
		return _instance;
	}

	//Class that will implement the singleton mode,
	//must use the macro in it's delare file
#define DECLARE_SINGLETON_CLASS( type )	friend class auto_ptr< type >; friend class Singleton< type >;
}
#endif // SINGLETON_H