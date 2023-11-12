# Приложение для построчного версионирования файла `ParentConfigurations.bin`

## Что делает?

- Делит файл на строки. Один объект поддержки - одна строка.
- К каждой строке добавляется имя объекта в 1С.

## Как управлять?

Приложение имеет команды 
- `convert` - делит исходный файл на строки и добавляет имена 1С
- `restore` - склеивает файл до исходного состояния (полное совпадение с исходным, включая BOM)
- `set-hook` - устанавливает хук `pre-commit`
- `info` - выводит информацию о поддержке в зависимости от опций

> PS: начальная реализация была выполнена через плагин `gitsync` (см. [здесь](https://github.com/240596448/gitsync-plugins/commit/8cc0744fd449ab72d108521ceb4cb57bc5adcc92)).  

## Как это работает?

Исходный файл состоит из множества записей `0,0,{ГУИД},{ГУИД},` записанных в одну строку  
Дубли `{ГУИД}` сокращаются. Каждый Гуид переносится на отдельную строку.

Из файла `ConfigDumpInfo.xml` читаются сопоставления гуидов именам объектов 1С. Имена каждого объекта поддержки добавляются в каждую строку.

Новые строки имеют вид `0,0,{ГУИД}, # Имя_в_1С`

## Какая польза?

При снятии объекта с поддержки или изменении режима поддержки в `git diff` теперь возможно увидеть измененнения по каждому объекту.

```sh
1,0,a3f5e643-b9c4-4763-9c5d-91fc9be92710, # Configuration.ДокументооборотКОРП
0,0,7c9bc131-bc25-474d-979f-b84ebdb2145c, # Language.Русский
0,0,adbb653b-752d-45cf-8b2d-6f6030c33b43, # Subsystem.АдминистрированиеСервиса
0,0,e4993f80-2a2f-4b8e-ad88-a9e2c93472a1, # Subsystem.АдминистрированиеСервиса.Subsystem.ОбластиДанных
0,0,b913837a-e6bf-4de3-8b61-9b742a1947ba, # Subsystem.АдминистрированиеСервиса.Subsystem.ОчередьЗаданий
0,0,000932fc-f508-4326-93c6-e2351be1cf25, # Subsystem.АдминистрированиеСервиса.Subsystem.ПоставляемыеДанные
0,0,4d475095-19b1-45f0-8864-d6f161f6da1a, # Subsystem.АдминистрированиеСервиса.Subsystem.РазмерПриложений
0,0,b0c18399-297a-4617-9d6e-3c02294ebd35, # Subsystem.АдминистрированиеСервиса.Subsystem.Сообщения
0,0,69f8b7f9-a81b-4b6a-88f7-2f2dccc11717, # Subsystem.АдминистрированиеСервиса.Subsystem.Тарификация
...
```

Командой `info` можно вывести объекты добавленные в конфигурацию (объекты без поддержки, см.опцию `--added`).  
Или посмотреть Все объекты снятые с подержки. (см.опцию `--filter`). Это так же можно сделать следующим скриптом.

```sh
grep ^[^0],-?0, src/Ext/ParentConfigurations.bin | perl -pe 's/,\w{8}-\w{4}-\w{4}-\w{4}-\w{12},//'
```

## Известные фишки

- `{6,0,3,...` - цифра `3` означает количество поставок в файле  

- _{6,0,3,ГУИД,0,ГУИД,"2.5.12.147","Фирма ""1С""","УправлениеПредприятием"_,`137634`,...  
  здесь последнее число - количество объектов в каждой поставке.
  
- `0,0,`_ГУИД_ 
  - первая цифра - вариант поддержки (см. [здесь](https://github.com/Stepa86/v8metadata-reader/blob/61b53bda9b90e8d21b38c1a60873ee9991aa8421/src/%D0%9A%D0%BB%D0%B0%D1%81%D1%81%D1%8B/%D0%9F%D0%BE%D0%B4%D0%B4%D0%B5%D1%80%D0%B6%D0%BA%D0%B0.os#L40), спасибо автору)  
  
	- 0 - на замке
	- 1 - на поддержке
	- 2 - снято с поддержки
	- 3 - нет поддержки
	- 4 - не удалось определить уровень поддержки.

  - вторая цифра режим поставки
	- 0 - изменения разрешены
	- 1 - измерения не рекомендуются
	- 2 - изменения запрещены
	- -1 - включение в конфигурацию не рекомендуется


- в последней строке `0,0,0,1,0,0,0,1,0,1,0,1,1,1,1,1,1,1,0,1,0,1,1,1,1,0,0,1,0,1,0,1,1,1,1}` каждые 10 цифр (с конца) принадлежат отдельной поставке. Предположительно являются флагами настроек обновления.
  