# KeyValueStore
## 数据缓存

``` objectivec
#define AccountPath [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"account.storage"]

KeyValueStore *store = [[KeyValueStore alloc]initWithPath:AccountPath];

NSDictionary *json = @{@"天王盖地虎":@"小鸡炖蘑菇"};
NSString *str = @"dd";
NSArray *array = @[@"aa",@"bb",@"cc"];
NSNumber *num = @(25);

[store yx_setObject:json forKey:@"json"];
[store yx_setObject:str forKey:@"str"];
[store yx_setObject:array forKey:@"array"];
[store yx_setObject:num forKey:@"num"];

NSLog(@"json = %@",[store yx_objectForKey:@"json"]);
NSLog(@"str = %@",[store yx_objectForKey:@"str"]);
NSLog(@"array = %@",[store yx_objectForKey:@"array"]);
NSLog(@"num = %@",[store yx_objectForKey:@"num"]);
NSLog(@"%zd",store.count);
```
