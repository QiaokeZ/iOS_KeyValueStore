
//
//  KeyValueStore.h
//  KeyValueStore <https://github.com/QiaokeZ/iOS_KeyValueStore>
//
//  Created by admin on 2019/1/18.
//  Copyright © 2019 zhouqiao. All rights reserved.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface KeyValueStore : NSObject

- (instancetype)initWithPath:(NSString *)path;
+ (instancetype)keyValueStoreWithPath:(NSString *)path;

@property (nonatomic, strong, readonly) NSString *path;
@property (nonatomic, strong, readonly) NSArray<NSString *> *allKeys;
@property (nonatomic, strong, readonly) NSArray<id<NSCoding>> *allValues;
@property (nonatomic, assign, readonly) NSUInteger count;

- (BOOL)yx_setObject:(id<NSCoding>)object forKey:(NSString *)key;

- (BOOL)yx_removeObjectForKey:(NSString *)key;
- (BOOL)yx_removeObjectsForKeys:(NSArray<NSString *> *)keys;
- (BOOL)yx_removeAllObjects;

- (BOOL)yx_containsObjectForKey:(NSString *)key;

- (nullable id)yx_objectForKey:(NSString *)key;
- (nullable NSArray *)yx_objectsForKeys:(NSArray<NSString *> *)keys;

@end
NS_ASSUME_NONNULL_END
