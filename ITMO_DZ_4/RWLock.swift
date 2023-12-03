//
//  RWLock.swift
//  ITMO_DZ_4
//
//  Created by Egor Nazarov on 02.12.2023.
//

import Foundation

class RWLock {
    private var lock = pthread_rwlock_t()
    
    public init() {
        guard pthread_rwlock_init (&lock, nil) == 0 else {
            fatalError("cant create rwlock")
        }
    }
    
    deinit {
        pthread_rwlock_destroy(&lock)
    }
    
    @discardableResult
    func writeLock() -> Bool {
        pthread_rwlock_wrlock(&lock) == 0
    }
        
    @discardableResult
    func readLock() -> Bool {
        pthread_rwlock_wrlock(&lock) == 0
//        pthread_rwlock_rdlock(&lock) == 0
    }
        
    @discardableResult
    func unlock() -> Bool {
        pthread_rwlock_unlock(&lock) == 0
    }
}
