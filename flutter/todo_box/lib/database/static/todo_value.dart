const String tableTodo = 'todo';

const String columnId = '_id';
const String columnTitle = 'title';
const String columnDone = 'done';
const String columnDate = 'date';
const String columnTags = 'tags';
const String columnNotification = 'notification';

const String typeId = '$columnId integer primary key autoincrement not null';
const String typeTitle = '$columnTitle text not null';
const String typeDone = '$columnDone integer not null';
const String typeDate = '$columnDate text null';
const String typeTags = '$columnTags text null';
const String typeNotification = '$columnNotification integer not null';
