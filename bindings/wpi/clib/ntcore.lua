---SPDX-FileCopyrightText: Michael Fisher @mfisher31
---SPDX-License-Identifier: MIT
local ffi = require('ffi')
local luabot = require ('luabot')

local SONAME = luabot.BUILD_TYPE == 'Debug' and 'ntcored' or 'ntcore'
local lib = nil

ffi.cdef [[
// ntcore_c.h
struct WPI_DataLog;
typedef int NT_Bool;
typedef unsigned int NT_Handle;
typedef NT_Handle NT_ConnectionDataLogger;
typedef NT_Handle NT_DataLogger;
typedef NT_Handle NT_Entry;
typedef NT_Handle NT_Inst;
typedef NT_Handle NT_Listener;
typedef NT_Handle NT_ListenerPoller;
typedef NT_Handle NT_MultiSubscriber;
typedef NT_Handle NT_Topic;
typedef NT_Handle NT_Subscriber;
typedef NT_Handle NT_Publisher;
// define NT_DEFAULT_PORT3 1735
// define NT_DEFAULT_PORT4 5810
enum {
    NT_DEFAULT_PORT3 = 1735,
    NT_DEFAULT_PORT4 = 5810
};

enum NT_Type {
  NT_UNASSIGNED = 0,
  NT_BOOLEAN = 0x01,
  NT_DOUBLE = 0x02,
  NT_STRING = 0x04,
  NT_RAW = 0x08,
  NT_BOOLEAN_ARRAY = 0x10,
  NT_DOUBLE_ARRAY = 0x20,
  NT_STRING_ARRAY = 0x40,
  NT_RPC = 0x80,
  NT_INTEGER = 0x100,
  NT_FLOAT = 0x200,
  NT_INTEGER_ARRAY = 0x400,
  NT_FLOAT_ARRAY = 0x800
};
enum NT_EntryFlags {
  NT_PERSISTENT = 0x01,
  NT_RETAINED = 0x02,
  NT_UNCACHED = 0x04
};
enum NT_LogLevel {
  NT_LOG_CRITICAL = 50,
  NT_LOG_ERROR = 40,
  NT_LOG_WARNING = 30,
  NT_LOG_INFO = 20,
  NT_LOG_DEBUG = 10,
  NT_LOG_DEBUG1 = 9,
  NT_LOG_DEBUG2 = 8,
  NT_LOG_DEBUG3 = 7,
  NT_LOG_DEBUG4 = 6
};
enum NT_NetworkMode {
  NT_NET_MODE_NONE = 0x00,
  NT_NET_MODE_SERVER = 0x01,
  NT_NET_MODE_CLIENT3 = 0x02,
  NT_NET_MODE_CLIENT4 = 0x04,
  NT_NET_MODE_STARTING = 0x08,
  NT_NET_MODE_LOCAL = 0x10,
};
enum NT_EventFlags {
  NT_EVENT_NONE = 0,
  NT_EVENT_IMMEDIATE = 0x01,
  NT_EVENT_CONNECTED = 0x02,
  NT_EVENT_DISCONNECTED = 0x04,
  NT_EVENT_CONNECTION = NT_EVENT_CONNECTED | NT_EVENT_DISCONNECTED,
  NT_EVENT_PUBLISH = 0x08,
  NT_EVENT_UNPUBLISH = 0x10,
  NT_EVENT_PROPERTIES = 0x20,
  NT_EVENT_TOPIC = NT_EVENT_PUBLISH | NT_EVENT_UNPUBLISH | NT_EVENT_PROPERTIES,
  NT_EVENT_VALUE_REMOTE = 0x40,
  NT_EVENT_VALUE_LOCAL = 0x80,
  NT_EVENT_VALUE_ALL = NT_EVENT_VALUE_REMOTE | NT_EVENT_VALUE_LOCAL,
  NT_EVENT_LOGMESSAGE = 0x100,
  NT_EVENT_TIMESYNC = 0x200,
};
struct NT_String {
  char* str;
  size_t len;
};
struct NT_Value {
  enum NT_Type type;
  int64_t last_change;
  int64_t server_time;
  union {
    NT_Bool v_boolean;
    int64_t v_int;
    float v_float;
    double v_double;
    struct NT_String v_string;
    struct {
      uint8_t* data;
      size_t size;
    } v_raw;
    struct {
      NT_Bool* arr;
      size_t size;
    } arr_boolean;
    struct {
      double* arr;
      size_t size;
    } arr_double;
    struct {
      float* arr;
      size_t size;
    } arr_float;
    struct {
      int64_t* arr;
      size_t size;
    } arr_int;
    struct {
      struct NT_String* arr;
      size_t size;
    } arr_string;
  } data;
};
struct NT_TopicInfo {
  NT_Topic topic;
  struct NT_String name;
  enum NT_Type type;
  struct NT_String type_str;
  struct NT_String properties;
};
struct NT_ConnectionInfo {
  struct NT_String remote_id;
  struct NT_String remote_ip;
  unsigned int remote_port;
  uint64_t last_update;
  unsigned int protocol_version;
};
struct NT_ValueEventData {
  NT_Topic topic;
  NT_Handle subentry;
  struct NT_Value value;
};
struct NT_LogMessage {
  unsigned int level;
  char* filename;
  unsigned int line;
  char* message;
};
struct NT_TimeSyncEventData {
  int64_t serverTimeOffset;
  int64_t rtt2;
  NT_Bool valid;
};
struct NT_Event {
  NT_Handle listener;
  unsigned int flags;
  union {
    struct NT_ConnectionInfo connInfo;
    struct NT_TopicInfo topicInfo;
    struct NT_ValueEventData valueData;
    struct NT_LogMessage logMessage;
    struct NT_TimeSyncEventData timeSyncData;
  } data;
};
struct NT_PubSubOptions {
  unsigned int structSize;
  unsigned int pollStorage;
  double periodic;
  NT_Publisher excludePublisher;
  NT_Bool sendAll;
  NT_Bool topicsOnly;
  NT_Bool prefixMatch;
  NT_Bool keepDuplicates;
  NT_Bool disableRemote;
  NT_Bool disableLocal;
  NT_Bool excludeSelf;
  NT_Bool hidden;
};
NT_Inst NT_GetDefaultInstance(void);
NT_Inst NT_CreateInstance(void);
void NT_DestroyInstance(NT_Inst inst);
NT_Inst NT_GetInstanceFromHandle(NT_Handle handle);
NT_Entry NT_GetEntry(NT_Inst inst, const char* name, size_t name_len);
char* NT_GetEntryName(NT_Entry entry, size_t* name_len);
enum NT_Type NT_GetEntryType(NT_Entry entry);
uint64_t NT_GetEntryLastChange(NT_Entry entry);
void NT_GetEntryValue(NT_Entry entry, struct NT_Value* value);
void NT_GetEntryValueType(NT_Entry entry, unsigned int types,
                          struct NT_Value* value);
NT_Bool NT_SetDefaultEntryValue(NT_Entry entry,
                                const struct NT_Value* default_value);
NT_Bool NT_SetEntryValue(NT_Entry entry, const struct NT_Value* value);
void NT_SetEntryFlags(NT_Entry entry, unsigned int flags);
unsigned int NT_GetEntryFlags(NT_Entry entry);
struct NT_Value* NT_ReadQueueValue(NT_Handle subentry, size_t* count);
struct NT_Value* NT_ReadQueueValueType(NT_Handle subentry, unsigned int types,
                                       size_t* count);
NT_Topic* NT_GetTopics(NT_Inst inst, const char* prefix, size_t prefix_len,
                       unsigned int types, size_t* count);
NT_Topic* NT_GetTopicsStr(NT_Inst inst, const char* prefix, size_t prefix_len,
                          const char* const* types, size_t types_len,
                          size_t* count);
struct NT_TopicInfo* NT_GetTopicInfos(NT_Inst inst, const char* prefix,
                                      size_t prefix_len, unsigned int types,
                                      size_t* count);
struct NT_TopicInfo* NT_GetTopicInfosStr(NT_Inst inst, const char* prefix,
                                         size_t prefix_len,
                                         const char* const* types,
                                         size_t types_len, size_t* count);
NT_Bool NT_GetTopicInfo(NT_Topic topic, struct NT_TopicInfo* info);
NT_Topic NT_GetTopic(NT_Inst inst, const char* name, size_t name_len);
char* NT_GetTopicName(NT_Topic topic, size_t* name_len);
enum NT_Type NT_GetTopicType(NT_Topic topic);
char* NT_GetTopicTypeString(NT_Topic topic, size_t* type_len);
void NT_SetTopicPersistent(NT_Topic topic, NT_Bool value);
NT_Bool NT_GetTopicPersistent(NT_Topic topic);
void NT_SetTopicRetained(NT_Topic topic, NT_Bool value);
NT_Bool NT_GetTopicRetained(NT_Topic topic);
void NT_SetTopicCached(NT_Topic topic, NT_Bool value);
NT_Bool NT_GetTopicCached(NT_Topic topic);
NT_Bool NT_GetTopicExists(NT_Handle handle);
char* NT_GetTopicProperty(NT_Topic topic, const char* name, size_t* len);
NT_Bool NT_SetTopicProperty(NT_Topic topic, const char* name,
                            const char* value);
void NT_DeleteTopicProperty(NT_Topic topic, const char* name);
char* NT_GetTopicProperties(NT_Topic topic, size_t* len);
NT_Bool NT_SetTopicProperties(NT_Topic topic, const char* properties);
NT_Subscriber NT_Subscribe(NT_Topic topic, enum NT_Type type,
                           const char* typeStr,
                           const struct NT_PubSubOptions* options);
void NT_Unsubscribe(NT_Subscriber sub);
NT_Publisher NT_Publish(NT_Topic topic, enum NT_Type type, const char* typeStr,
                        const struct NT_PubSubOptions* options);
NT_Publisher NT_PublishEx(NT_Topic topic, enum NT_Type type,
                          const char* typeStr, const char* properties,
                          const struct NT_PubSubOptions* options);
void NT_Unpublish(NT_Handle pubentry);
NT_Entry NT_GetEntryEx(NT_Topic topic, enum NT_Type type, const char* typeStr,
                       const struct NT_PubSubOptions* options);
void NT_ReleaseEntry(NT_Entry entry);
void NT_Release(NT_Handle pubsubentry);
NT_Topic NT_GetTopicFromHandle(NT_Handle pubsubentry);
NT_MultiSubscriber NT_SubscribeMultiple(NT_Inst inst,
                                        const struct NT_String* prefixes,
                                        size_t prefixes_len,
                                        const struct NT_PubSubOptions* options);
void NT_UnsubscribeMultiple(NT_MultiSubscriber sub);
typedef void (*NT_ListenerCallback)(void* data, const struct NT_Event* event);
NT_ListenerPoller NT_CreateListenerPoller(NT_Inst inst);
void NT_DestroyListenerPoller(NT_ListenerPoller poller);
struct NT_Event* NT_ReadListenerQueue(NT_ListenerPoller poller, size_t* len);
void NT_RemoveListener(NT_Listener listener);
NT_Bool NT_WaitForListenerQueue(NT_Handle handle, double timeout);
NT_Listener NT_AddListenerSingle(NT_Inst inst, const char* prefix,
                                 size_t prefix_len, unsigned int mask,
                                 void* data, NT_ListenerCallback callback);
NT_Listener NT_AddListenerMultiple(NT_Inst inst,
                                   const struct NT_String* prefixes,
                                   size_t prefixes_len, unsigned int mask,
                                   void* data, NT_ListenerCallback callback);
NT_Listener NT_AddListener(NT_Handle handle, unsigned int mask, void* data,
                           NT_ListenerCallback callback);
NT_Listener NT_AddPolledListenerSingle(NT_ListenerPoller poller,
                                       const char* prefix, size_t prefix_len,
                                       unsigned int mask);
NT_Listener NT_AddPolledListenerMultiple(NT_ListenerPoller poller,
                                         const struct NT_String* prefixes,
                                         size_t prefixes_len,
                                         unsigned int mask);
NT_Listener NT_AddPolledListener(NT_ListenerPoller poller, NT_Handle handle,
                                 unsigned int mask);
unsigned int NT_GetNetworkMode(NT_Inst inst);
void NT_StartLocal(NT_Inst inst);
void NT_StopLocal(NT_Inst inst);
void NT_StartServer(NT_Inst inst, const char* persist_filename,
                    const char* listen_address, unsigned int port3,
                    unsigned int port4);
void NT_StopServer(NT_Inst inst);
void NT_StartClient3(NT_Inst inst, const char* identity);
void NT_StartClient4(NT_Inst inst, const char* identity);
void NT_StopClient(NT_Inst inst);
void NT_SetServer(NT_Inst inst, const char* server_name, unsigned int port);
void NT_SetServerMulti(NT_Inst inst, size_t count, const char** server_names,
                       const unsigned int* ports);
void NT_SetServerTeam(NT_Inst inst, unsigned int team, unsigned int port);
void NT_Disconnect(NT_Inst inst);
void NT_StartDSClient(NT_Inst inst, unsigned int port);
void NT_StopDSClient(NT_Inst inst);
void NT_FlushLocal(NT_Inst inst);
void NT_Flush(NT_Inst inst);
struct NT_ConnectionInfo* NT_GetConnections(NT_Inst inst, size_t* count);
NT_Bool NT_IsConnected(NT_Inst inst);
int64_t NT_GetServerTimeOffset(NT_Inst inst, NT_Bool* valid);
void NT_DisposeValue(struct NT_Value* value);
void NT_InitValue(struct NT_Value* value);
void NT_DisposeString(struct NT_String* str);
void NT_InitString(struct NT_String* str);
void NT_DisposeValueArray(struct NT_Value* arr, size_t count);
void NT_DisposeConnectionInfoArray(struct NT_ConnectionInfo* arr, size_t count);
void NT_DisposeTopicInfoArray(struct NT_TopicInfo* arr, size_t count);
void NT_DisposeTopicInfo(struct NT_TopicInfo* info);
void NT_DisposeEventArray(struct NT_Event* arr, size_t count);
void NT_DisposeEvent(struct NT_Event* event);
int64_t NT_Now(void);
void NT_SetNow(int64_t timestamp);
NT_DataLogger NT_StartEntryDataLog(NT_Inst inst, struct WPI_DataLog* log,
                                   const char* prefix, const char* logPrefix);
void NT_StopEntryDataLog(NT_DataLogger logger);
NT_ConnectionDataLogger NT_StartConnectionDataLog(NT_Inst inst,
                                                  struct WPI_DataLog* log,
                                                  const char* name);
void NT_StopConnectionDataLog(NT_ConnectionDataLogger logger);
NT_Listener NT_AddLogger(NT_Inst inst, unsigned int min_level,
                         unsigned int max_level, void* data,
                         NT_ListenerCallback func);
NT_Listener NT_AddPolledLogger(NT_ListenerPoller poller, unsigned int min_level,
                               unsigned int max_level);
NT_Bool NT_HasSchema(NT_Inst inst, const char* name);
void NT_AddSchema(NT_Inst inst, const char* name, const char* type,
                  const uint8_t* schema, size_t schemaSize);
char* NT_AllocateCharArray(size_t size);
NT_Bool* NT_AllocateBooleanArray(size_t size);
int64_t* NT_AllocateIntegerArray(size_t size);
float* NT_AllocateFloatArray(size_t size);
double* NT_AllocateDoubleArray(size_t size);
struct NT_String* NT_AllocateStringArray(size_t size);
void NT_FreeCharArray(char* v_char);
void NT_FreeBooleanArray(NT_Bool* v_boolean);
void NT_FreeIntegerArray(int64_t* v_int);
void NT_FreeFloatArray(float* v_float);
void NT_FreeDoubleArray(double* v_double);
void NT_FreeStringArray(struct NT_String* v_string, size_t arr_size);
enum NT_Type NT_GetValueType(const struct NT_Value* value);
NT_Bool NT_GetValueBoolean(const struct NT_Value* value, uint64_t* last_change,
                           NT_Bool* v_boolean);
NT_Bool NT_GetValueInteger(const struct NT_Value* value, uint64_t* last_change,
                           int64_t* v_int);
NT_Bool NT_GetValueFloat(const struct NT_Value* value, uint64_t* last_change,
                         float* v_float);
NT_Bool NT_GetValueDouble(const struct NT_Value* value, uint64_t* last_change,
                          double* v_double);
char* NT_GetValueString(const struct NT_Value* value, uint64_t* last_change,
                        size_t* str_len);
uint8_t* NT_GetValueRaw(const struct NT_Value* value, uint64_t* last_change,
                        size_t* raw_len);
NT_Bool* NT_GetValueBooleanArray(const struct NT_Value* value,
                                 uint64_t* last_change, size_t* arr_size);
int64_t* NT_GetValueIntegerArray(const struct NT_Value* value,
                                 uint64_t* last_change, size_t* arr_size);
float* NT_GetValueFloatArray(const struct NT_Value* value,
                             uint64_t* last_change, size_t* arr_size);
double* NT_GetValueDoubleArray(const struct NT_Value* value,
                               uint64_t* last_change, size_t* arr_size);
struct NT_String* NT_GetValueStringArray(const struct NT_Value* value,
                                         uint64_t* last_change,
                                         size_t* arr_size);
struct NT_Meta_SubscriberOptions {
  double periodic;
  NT_Bool topicsOnly;
  NT_Bool sendAll;
  NT_Bool prefixMatch;
};
struct NT_Meta_TopicPublisher {
  struct NT_String client;
  uint64_t pubuid;
};
struct NT_Meta_TopicSubscriber {
  struct NT_String client;
  uint64_t subuid;
  struct NT_Meta_SubscriberOptions options;
};
struct NT_Meta_ClientPublisher {
  int64_t uid;
  struct NT_String topic;
};
struct NT_Meta_ClientSubscriber {
  int64_t uid;
  size_t topicsCount;
  struct NT_String* topics;
  struct NT_Meta_SubscriberOptions options;
};
struct NT_Meta_Client {
  struct NT_String id;
  struct NT_String conn;
  uint16_t version;
};
struct NT_Meta_TopicPublisher* NT_Meta_DecodeTopicPublishers(
    const uint8_t* data, size_t size, size_t* count);
struct NT_Meta_TopicSubscriber* NT_Meta_DecodeTopicSubscribers(
    const uint8_t* data, size_t size, size_t* count);
struct NT_Meta_ClientPublisher* NT_Meta_DecodeClientPublishers(
    const uint8_t* data, size_t size, size_t* count);
struct NT_Meta_ClientSubscriber* NT_Meta_DecodeClientSubscribers(
    const uint8_t* data, size_t size, size_t* count);
struct NT_Meta_Client* NT_Meta_DecodeClients(const uint8_t* data, size_t size,
                                             size_t* count);
void NT_Meta_FreeTopicPublishers(struct NT_Meta_TopicPublisher* arr,
                                 size_t count);
void NT_Meta_FreeTopicSubscribers(struct NT_Meta_TopicSubscriber* arr,
                                  size_t count);
void NT_Meta_FreeClientPublishers(struct NT_Meta_ClientPublisher* arr,
                                  size_t count);
void NT_Meta_FreeClientSubscribers(struct NT_Meta_ClientSubscriber* arr,
                                   size_t count);
void NT_Meta_FreeClients(struct NT_Meta_Client* arr, size_t count);
]]

ffi.cdef [[
// ntcore_c_types.h

struct NT_TimestampedBoolean {
  int64_t time;
  int64_t serverTime;
  NT_Bool value;
};
NT_Bool NT_SetBoolean(NT_Handle pubentry, int64_t time, NT_Bool value);
NT_Bool NT_SetDefaultBoolean(NT_Handle pubentry, NT_Bool defaultValue);
NT_Bool NT_GetBoolean(NT_Handle subentry, NT_Bool defaultValue);
void NT_GetAtomicBoolean(NT_Handle subentry, NT_Bool defaultValue, struct NT_TimestampedBoolean* value);
void NT_DisposeTimestampedBoolean(struct NT_TimestampedBoolean* value);
struct NT_TimestampedBoolean* NT_ReadQueueBoolean(NT_Handle subentry, size_t* len);
void NT_FreeQueueBoolean(struct NT_TimestampedBoolean* arr, size_t len);
NT_Bool* NT_ReadQueueValuesBoolean(NT_Handle subentry, size_t* len);
struct NT_TimestampedInteger {
  int64_t time;
  int64_t serverTime;
  int64_t value;
};
NT_Bool NT_SetInteger(NT_Handle pubentry, int64_t time, int64_t value);
NT_Bool NT_SetDefaultInteger(NT_Handle pubentry, int64_t defaultValue);
int64_t NT_GetInteger(NT_Handle subentry, int64_t defaultValue);
void NT_GetAtomicInteger(NT_Handle subentry, int64_t defaultValue, struct NT_TimestampedInteger* value);
void NT_DisposeTimestampedInteger(struct NT_TimestampedInteger* value);
struct NT_TimestampedInteger* NT_ReadQueueInteger(NT_Handle subentry, size_t* len);
void NT_FreeQueueInteger(struct NT_TimestampedInteger* arr, size_t len);
int64_t* NT_ReadQueueValuesInteger(NT_Handle subentry, size_t* len);
struct NT_TimestampedFloat {
  int64_t time;
  int64_t serverTime;
  float value;
};
NT_Bool NT_SetFloat(NT_Handle pubentry, int64_t time, float value);
NT_Bool NT_SetDefaultFloat(NT_Handle pubentry, float defaultValue);
float NT_GetFloat(NT_Handle subentry, float defaultValue);
void NT_GetAtomicFloat(NT_Handle subentry, float defaultValue, struct NT_TimestampedFloat* value);
void NT_DisposeTimestampedFloat(struct NT_TimestampedFloat* value);
struct NT_TimestampedFloat* NT_ReadQueueFloat(NT_Handle subentry, size_t* len);
void NT_FreeQueueFloat(struct NT_TimestampedFloat* arr, size_t len);
float* NT_ReadQueueValuesFloat(NT_Handle subentry, size_t* len);
struct NT_TimestampedDouble {
  int64_t time;
  int64_t serverTime;
  double value;
};
NT_Bool NT_SetDouble(NT_Handle pubentry, int64_t time, double value);
NT_Bool NT_SetDefaultDouble(NT_Handle pubentry, double defaultValue);
double NT_GetDouble(NT_Handle subentry, double defaultValue);
void NT_GetAtomicDouble(NT_Handle subentry, double defaultValue, struct NT_TimestampedDouble* value);
void NT_DisposeTimestampedDouble(struct NT_TimestampedDouble* value);
struct NT_TimestampedDouble* NT_ReadQueueDouble(NT_Handle subentry, size_t* len);
void NT_FreeQueueDouble(struct NT_TimestampedDouble* arr, size_t len);
double* NT_ReadQueueValuesDouble(NT_Handle subentry, size_t* len);
struct NT_TimestampedString {
  int64_t time;
  int64_t serverTime;
  char* value;
  size_t len;
};
NT_Bool NT_SetString(NT_Handle pubentry, int64_t time, const char* value, size_t len);
NT_Bool NT_SetDefaultString(NT_Handle pubentry, const char* defaultValue, size_t defaultValueLen);
char* NT_GetString(NT_Handle subentry, const char* defaultValue, size_t defaultValueLen, size_t* len);
void NT_GetAtomicString(NT_Handle subentry, const char* defaultValue, size_t defaultValueLen, struct NT_TimestampedString* value);
void NT_DisposeTimestampedString(struct NT_TimestampedString* value);
struct NT_TimestampedString* NT_ReadQueueString(NT_Handle subentry, size_t* len);
void NT_FreeQueueString(struct NT_TimestampedString* arr, size_t len);
struct NT_TimestampedRaw {
  int64_t time;
  int64_t serverTime;
  uint8_t* value;
  size_t len;
};
NT_Bool NT_SetRaw(NT_Handle pubentry, int64_t time, const uint8_t* value, size_t len);
NT_Bool NT_SetDefaultRaw(NT_Handle pubentry, const uint8_t* defaultValue, size_t defaultValueLen);
uint8_t* NT_GetRaw(NT_Handle subentry, const uint8_t* defaultValue, size_t defaultValueLen, size_t* len);
void NT_GetAtomicRaw(NT_Handle subentry, const uint8_t* defaultValue, size_t defaultValueLen, struct NT_TimestampedRaw* value);
void NT_DisposeTimestampedRaw(struct NT_TimestampedRaw* value);
struct NT_TimestampedRaw* NT_ReadQueueRaw(NT_Handle subentry, size_t* len);
void NT_FreeQueueRaw(struct NT_TimestampedRaw* arr, size_t len);
struct NT_TimestampedBooleanArray {
  int64_t time;
  int64_t serverTime;
  NT_Bool* value;
  size_t len;
};
NT_Bool NT_SetBooleanArray(NT_Handle pubentry, int64_t time, const NT_Bool* value, size_t len);
NT_Bool NT_SetDefaultBooleanArray(NT_Handle pubentry, const NT_Bool* defaultValue, size_t defaultValueLen);
NT_Bool* NT_GetBooleanArray(NT_Handle subentry, const NT_Bool* defaultValue, size_t defaultValueLen, size_t* len);
void NT_GetAtomicBooleanArray(NT_Handle subentry, const NT_Bool* defaultValue, size_t defaultValueLen, struct NT_TimestampedBooleanArray* value);
void NT_DisposeTimestampedBooleanArray(struct NT_TimestampedBooleanArray* value);
struct NT_TimestampedBooleanArray* NT_ReadQueueBooleanArray(NT_Handle subentry, size_t* len);
void NT_FreeQueueBooleanArray(struct NT_TimestampedBooleanArray* arr, size_t len);
struct NT_TimestampedIntegerArray {
  int64_t time;
  int64_t serverTime;
  int64_t* value;
  size_t len;
};
NT_Bool NT_SetIntegerArray(NT_Handle pubentry, int64_t time, const int64_t* value, size_t len);
NT_Bool NT_SetDefaultIntegerArray(NT_Handle pubentry, const int64_t* defaultValue, size_t defaultValueLen);
int64_t* NT_GetIntegerArray(NT_Handle subentry, const int64_t* defaultValue, size_t defaultValueLen, size_t* len);
void NT_GetAtomicIntegerArray(NT_Handle subentry, const int64_t* defaultValue, size_t defaultValueLen, struct NT_TimestampedIntegerArray* value);
void NT_DisposeTimestampedIntegerArray(struct NT_TimestampedIntegerArray* value);
struct NT_TimestampedIntegerArray* NT_ReadQueueIntegerArray(NT_Handle subentry, size_t* len);
void NT_FreeQueueIntegerArray(struct NT_TimestampedIntegerArray* arr, size_t len);
struct NT_TimestampedFloatArray {
  int64_t time;
  int64_t serverTime;
  float* value;
  size_t len;
};
NT_Bool NT_SetFloatArray(NT_Handle pubentry, int64_t time, const float* value, size_t len);
NT_Bool NT_SetDefaultFloatArray(NT_Handle pubentry, const float* defaultValue, size_t defaultValueLen);
float* NT_GetFloatArray(NT_Handle subentry, const float* defaultValue, size_t defaultValueLen, size_t* len);
void NT_GetAtomicFloatArray(NT_Handle subentry, const float* defaultValue, size_t defaultValueLen, struct NT_TimestampedFloatArray* value);
void NT_DisposeTimestampedFloatArray(struct NT_TimestampedFloatArray* value);
struct NT_TimestampedFloatArray* NT_ReadQueueFloatArray(NT_Handle subentry, size_t* len);
void NT_FreeQueueFloatArray(struct NT_TimestampedFloatArray* arr, size_t len);
struct NT_TimestampedDoubleArray {
  int64_t time;
  int64_t serverTime;
  double* value;
  size_t len;
};
NT_Bool NT_SetDoubleArray(NT_Handle pubentry, int64_t time, const double* value, size_t len);
NT_Bool NT_SetDefaultDoubleArray(NT_Handle pubentry, const double* defaultValue, size_t defaultValueLen);
double* NT_GetDoubleArray(NT_Handle subentry, const double* defaultValue, size_t defaultValueLen, size_t* len);
void NT_GetAtomicDoubleArray(NT_Handle subentry, const double* defaultValue, size_t defaultValueLen, struct NT_TimestampedDoubleArray* value);
void NT_DisposeTimestampedDoubleArray(struct NT_TimestampedDoubleArray* value);
struct NT_TimestampedDoubleArray* NT_ReadQueueDoubleArray(NT_Handle subentry, size_t* len);
void NT_FreeQueueDoubleArray(struct NT_TimestampedDoubleArray* arr, size_t len);
struct NT_TimestampedStringArray {
  int64_t time;
  int64_t serverTime;
  struct NT_String* value;
  size_t len;
};
NT_Bool NT_SetStringArray(NT_Handle pubentry, int64_t time, const struct NT_String* value, size_t len);
NT_Bool NT_SetDefaultStringArray(NT_Handle pubentry, const struct NT_String* defaultValue, size_t defaultValueLen);
struct NT_String* NT_GetStringArray(NT_Handle subentry, const struct NT_String* defaultValue, size_t defaultValueLen, size_t* len);
void NT_GetAtomicStringArray(NT_Handle subentry, const struct NT_String* defaultValue, size_t defaultValueLen, struct NT_TimestampedStringArray* value);
void NT_DisposeTimestampedStringArray(struct NT_TimestampedStringArray* value);
struct NT_TimestampedStringArray* NT_ReadQueueStringArray(NT_Handle subentry, size_t* len);
void NT_FreeQueueStringArray(struct NT_TimestampedStringArray* arr, size_t len);
]]

---Load the ntcore shared library.
---@param global boolean? Set true to add to the `ffi.C` namespace
---@return ffi.namespace* clib The shared library ref
local function load(global)
    if not lib then
        lib = ffi.load(SONAME, global)
    end
    return lib
end

return { load = load }
