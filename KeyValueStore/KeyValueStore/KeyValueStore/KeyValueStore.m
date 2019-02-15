

#import "KeyValueStore.h"
#import <sqlite3.h>

@interface KeyValueStore (){
    sqlite3 *_db;
    dispatch_semaphore_t _semaphore;
}
@end

@implementation KeyValueStore

- (instancetype)initWithPath:(NSString *)path{
    if(self = [super init]){
        _path = path.copy;
        _semaphore = dispatch_semaphore_create(1);
        if(sqlite3_open(_path.UTF8String, &_db) == SQLITE_OK){
            static const char *sql = "create table if not exists KeyValueStore (key text primary key, value blob);";
            char *error = NULL;
            if(sqlite3_exec(_db, sql, NULL, NULL, &error) != SQLITE_OK){
                NSLog(@"KeyValueStore 失败");
            }
        }else{
            NSLog(@"KeyValueStore 失败");
        }
        sqlite3_close(_db);
    }
    return self;
}

+ (instancetype)keyValueStoreWithPath:(NSString *)path{
    KeyValueStore *store = [[KeyValueStore alloc]initWithPath:path];
    return store;
}

- (BOOL)openDB{
    if(sqlite3_open(_path.UTF8String, &_db) == SQLITE_OK){
        return YES;
    }
    NSLog(@"失败");
    return NO;
}

- (BOOL)yx_setObject:(id<NSCoding>)object forKey:(NSString *)key{
    if (object && key){
        dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
        BOOL result = NO;
        if([self openDB]){
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:object];
            static const char *sql = "insert or replace into KeyValueStore (key, value) values (?, ?);";
            sqlite3_stmt *stmt = NULL;
            if (sqlite3_prepare_v2(_db, sql, -1, &stmt, NULL) == SQLITE_OK)  {
                sqlite3_bind_text(stmt, 1, key.UTF8String, -1, NULL);
                sqlite3_bind_blob(stmt, 2, data.bytes, (int)data.length, NULL);
                if(sqlite3_step(stmt) == SQLITE_DONE)  {
                    result = YES;
                }
            }
            sqlite3_finalize(stmt);
            sqlite3_close(_db);
        }
        dispatch_semaphore_signal(_semaphore);
        return result;
    }
    return NO;
}

- (BOOL)yx_removeObjectForKey:(NSString *)key{
    if(key){
        dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
        BOOL result = NO;
        if([self openDB]){
            static const char *sql = "delete from KeyValueStore where key = ?;";
            sqlite3_stmt *stmt = NULL;
            if (sqlite3_prepare_v2(_db, sql, -1, &stmt, NULL) == SQLITE_OK) {
                sqlite3_bind_text(stmt, 1, key.UTF8String, -1, NULL);
                if(sqlite3_step(stmt) == SQLITE_DONE)  {
                    result = YES;
                }
            }
            sqlite3_finalize(stmt);
            sqlite3_close(_db);
        }
    }
    dispatch_semaphore_signal(_semaphore);
    return NO;
}

- (BOOL)yx_removeObjectsForKeys:(NSArray<NSString *> *)keys{
    if(keys){
        dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
        BOOL result = NO;
        if([self openDB]){
            NSString *key = [keys componentsJoinedByString:@","];
            NSString *sql = [NSString stringWithFormat:@"delete from KeyValueStore where key in (%@);", key];
            sqlite3_stmt *stmt = NULL;
            if (sqlite3_prepare_v2(_db, sql.UTF8String, -1, &stmt, NULL) == SQLITE_OK) {
                NSInteger count = keys.count;
                for (int i = 0; i < count; i++) {
                    NSString *key = keys[i];
                    sqlite3_bind_text(stmt, 1 + i, key.UTF8String, -1, NULL);
                }
                if(sqlite3_step(stmt) == SQLITE_DONE)  {
                    result = YES;
                }
            }
            sqlite3_finalize(stmt);
            sqlite3_close(_db);
        }
        dispatch_semaphore_signal(_semaphore);
        return result;
    }
    return NO;
}

- (BOOL)yx_removeAllObjects{
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    BOOL result = NO;
    if([self openDB]){
        static const char *sql = "drop table if exists KeyValueStore;";
        char *error = NULL;
        if(sqlite3_exec(_db, sql, NULL, NULL, &error)){
            result = YES;
        }
        sqlite3_close(_db);
    }
    dispatch_semaphore_signal(_semaphore);
    return result;
}

- (BOOL)yx_containsObjectForKey:(NSString *)key{
    if(key){
        dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
        BOOL result = NO;
        if([self openDB]){
            static const char *sql = "select count(key) from KeyValueStore where key = ?;";
            sqlite3_stmt *stmt = NULL;
            if (sqlite3_prepare_v2(_db, sql, -1, &stmt, NULL) == SQLITE_OK) {
                sqlite3_bind_text(stmt, 1, key.UTF8String, -1, NULL);
                if(sqlite3_step(stmt) == SQLITE_ROW)  {
                    result = sqlite3_column_int(stmt, 0);
                }
            }
            sqlite3_finalize(stmt);
            sqlite3_close(_db);
        }
        dispatch_semaphore_signal(_semaphore);
        return result;
    }
    return NO;
}

- (id)yx_objectForKey:(NSString *)key{
    if(key){
        dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
        id value = nil;
        if([self openDB]){
            static const char *sql = "select value from KeyValueStore where key = ?;";
            sqlite3_stmt *stmt = NULL;
            if (sqlite3_prepare_v2(_db, sql, -1, &stmt, NULL) == SQLITE_OK) {
                sqlite3_bind_text(stmt, 1, key.UTF8String, -1, NULL);
                if(sqlite3_step(stmt) == SQLITE_ROW)  {
                    const void *bytes = sqlite3_column_blob(stmt, 0);
                    int length = sqlite3_column_bytes(stmt, 0);
                    NSData *data = [NSData dataWithBytes:bytes length:length];
                    value = [NSKeyedUnarchiver unarchiveObjectWithData:data];
                }
            }
            sqlite3_finalize(stmt);
            sqlite3_close(_db);
        }
        dispatch_semaphore_signal(_semaphore);
        return value;
    }
    return nil;
}

- (NSArray *)yx_objectsForKeys:(NSArray<NSString *> *)keys{
    if(keys){
        dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
        id value = nil;
        if([self openDB]){
            NSString *key = [keys componentsJoinedByString:@","];
            NSString *sql = [NSString stringWithFormat:@"select value from KeyValueStore where key in (%@);", key];
            sqlite3_stmt *stmt = NULL;
            if (sqlite3_prepare_v2(_db, sql.UTF8String, -1, &stmt, NULL) == SQLITE_OK) {
                NSInteger count = keys.count;
                for (int i = 0; i < count; i++) {
                    NSString *key = keys[i];
                    sqlite3_bind_text(stmt, 1 + i, key.UTF8String, -1, NULL);
                }
                NSMutableArray *values = [NSMutableArray array];
                while (YES) {
                    if(sqlite3_step(stmt) == SQLITE_ROW)  {
                        const void *bytes = sqlite3_column_blob(stmt, 0);
                        int length = sqlite3_column_bytes(stmt, 0);
                        NSData *data = [NSData dataWithBytes:bytes length:length];
                        id item = [NSKeyedUnarchiver unarchiveObjectWithData:data];
                        [values addObject:item];
                    }else{
                        break;
                    }
                }
                value = values.copy;
            }
            sqlite3_finalize(stmt);
            sqlite3_close(_db);
        }
        dispatch_semaphore_signal(_semaphore);
        return value;
    }
    return nil;
}

- (NSArray<NSString *> *)allKeys{
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    id keys = nil;
    if([self openDB]){
        static const char *sql = "select key from KeyValueStore;";
        sqlite3_stmt *stmt = NULL;
        if (sqlite3_prepare_v2(_db, sql, -1, &stmt, NULL) == SQLITE_OK) {
            NSMutableArray *keys = [NSMutableArray array];
            while (YES) {
                if(sqlite3_step(stmt) == SQLITE_ROW)  {
                    const char *key = (char *)sqlite3_column_text(stmt, 0);
                    [keys addObject:[NSString stringWithUTF8String:key]];
                }else{
                    break;
                }
            }
            keys = keys.copy;
        }
        sqlite3_finalize(stmt);
        sqlite3_close(_db);
    }
    dispatch_semaphore_signal(_semaphore);
    return keys;
}

- (NSArray<id<NSCoding>> *)allValues{
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    id values = nil;
    if([self openDB]){
        static const char *sql = "select value from KeyValueStore;";
        sqlite3_stmt *stmt = NULL;
        if (sqlite3_prepare_v2(_db, sql, -1, &stmt, NULL) == SQLITE_OK) {
            NSMutableArray *values = [NSMutableArray array];
            while (YES) {
                if(sqlite3_step(stmt) == SQLITE_ROW)  {
                    const void *bytes = sqlite3_column_blob(stmt, 0);
                    int length = sqlite3_column_bytes(stmt, 0);
                    NSData *data = [NSData dataWithBytes:bytes length:length];
                    id item = [NSKeyedUnarchiver unarchiveObjectWithData:data];
                    [values addObject:item];
                }else{
                    break;
                }
            }
            values = values.copy;
        }
        sqlite3_finalize(stmt);
        sqlite3_close(_db);
    }
    dispatch_semaphore_signal(_semaphore);
    return values;
}

- (NSUInteger)count{
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    int result = 0;
    if([self openDB]){
        static const char *sql = "select count(*) from KeyValueStore;";
        sqlite3_stmt *stmt = NULL;
        if (sqlite3_prepare_v2(_db, sql, -1, &stmt, NULL) == SQLITE_OK) {
            if(sqlite3_step(stmt) == SQLITE_ROW)  {
                result = sqlite3_column_int(stmt, 0);
            }
        }
        sqlite3_finalize(stmt);
        sqlite3_close(_db);
    }
    dispatch_semaphore_signal(_semaphore);
    return result;
}
@end
