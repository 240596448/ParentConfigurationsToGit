Процедура ОписаниеКоманды(Команда) Экспорт

	Команда.Аргумент("REPO", , 
				"Путь к git-репозиторию для установки hook pre-commit")
				.ТСтрока()
				.Обязательный(Истина);

	Команда.Опция("hv hook-version", 1, "Вариант хука (см templates)
				|			- 1: конвертация без создания файла кэша
				|			- 2: grep-кэш (без сортировки) + чтение сопоставлений из кэш-файла + конвертация
				|			- 3: чтение дампа 1С + кэширование с сортировкой (при конвертации) + конвертация
				|			- 4: кэширование с сортировкой (при конвертации)
				|			")
				.ТЧисло()
				.Обязательный(Истина);

	Команда.Опция("in orig", "src/Ext/ParentConfigurations.bin", 
				"Относительный путь к файлу ParentConfigurations.bin внутри репозитория")
				.ТСтрока();
				
	Команда.Опция("out mod", "src/Ext/ParentConfigurations_mod.bin", 
				"Относительный путь к сконвертированному файлу внутри репозитория")
				.ТСтрока();

	Команда.Опция("dump", "src/ConfigDumpInfo.xml", 
				"Путь к файлу ConfigDump* внутри репозитория для получения соотвествия Id-Name. Файл должен содержать строки вида 'name=""Имя"" id=""Гуид""'
				|			")
				.ТСтрока();
				
	Команда.Опция("dump-cache", "mod/ConfigID.xml", 
				"Сохранять пары Name-Id, полученные из дампа, в отдельный файл (например, mod/ConfigID.xml)")
				.ТСтрока();
				
КонецПроцедуры

// Выполняет логику команды
Процедура ВыполнитьКоманду(Знач Команда) Экспорт

	ВариантШаблона                = Команда.ЗначениеОпции("hv");

	КаталогРепозитория            = Команда.ЗначениеАргумента("REPO");
	ПутьКФайлуПоддержки           = Команда.ЗначениеОпции("in");
	ПутьКНовомуФайлуПоддержки     = Команда.ЗначениеОпции("out");
	ПутьКФайлуДампа               = Команда.ЗначениеОпции("dump");
	ПутьКФайлуКэшаИдентификаторов = Команда.ЗначениеОпции("dump-cache");

	ФайлПуть = Новый Файл(КаталогРепозитория);
	Если НЕ ФайлПуть.ЭтоКаталог() Тогда
		ВызватьИсключение СтрШаблон("Путь %1 не является каталогом. Укажите каталог репозитория", КаталогРепозитория);
	КонецЕсли;

	Файлы = НайтиФайлы(КаталогРепозитория, ".git", Истина);
	Если Файлы.Количество() = 0 Тогда
		ВызватьИсключение СтрШаблон("GIT-репозиторий не найден или не инициализирован: %1", ФайлПуть.ПолноеИмя);
	
	ИначеЕсли Файлы.Количество() > 1 Тогда
		ТекстОшибки = Новый Массив();
		ТекстОшибки.Добавить(СтрШаблон("Обнаружено более одного GIT-репозитория в папке: %1", ФайлПуть.ПолноеИмя));
		Для каждого Файл Из Файлы Цикл
			ТекстОшибки.Добавить(Файл.ПолноеИмя);
		КонецЦикла;
		ВызватьИсключение СтрСоединить(ТекстОшибки, Символы.ПС);
	
	ИначеЕсли НЕ Файлы[0].ЭтоКаталог() Тогда
		ВызватьИсключение "Файл .git не является каталогом"

	КонецЕсли;

	ПутьКHooks = ОбъединитьПути(Файлы[0].ПолноеИмя, "hooks");
	ПутьКPrecommit = ОбъединитьПути(ПутьКHooks, "pre-commit");
	ИмяПриложения = ПараметрыПриложения.Имя();

	ПутьКШаблонам = ПараметрыПриложения.ПутьКШаблонам();
	ТекстШаблона = ОбщегоНазначения.ПрочитатьФайлВТекст(ОбъединитьПути(ПутьКШаблонам, "pre-commit-" + ВариантШаблона));

	Файл = Новый Файл(ПутьКPrecommit);
	Если Файл.Существует() Тогда
		Текст = ОбщегоНазначения.ПрочитатьФайлВТекст(ПутьКPrecommit);
		НовыйТекст = Новый Массив();
		Для НомерСтроки = 1 По СтрЧислоСтрок(Текст) Цикл
			Строка = СтрПолучитьСтроку(Текст, НомерСтроки);
			Если НЕ ПустаяСтрока(Строка) И СтрНайти(Строка, ИмяПриложения) = 0 Тогда
				НовыйТекст.Добавить(Строка);
			КонецЕсли;
		КонецЦикла;
		Если ПустаяСтрока(СокрЛП(СтрСоединить(НовыйТекст, ""))) Тогда
			НачальнаяСтрока = 1;
		Иначе
			НачальнаяСтрока = 2;
		КонецЕсли;
		Для НомерСтроки = НачальнаяСтрока По СтрЧислоСтрок(ТекстШаблона) Цикл
			НовыйТекст.Добавить(СтрПолучитьСтроку(ТекстШаблона, НомерСтроки));
		КонецЦикла;
		ТекстФайла = СтрСоединить(НовыйТекст, Символы.ПС);
		Сообщить("Дополнен файл хука: " + ПутьКPrecommit);
	Иначе
		ТекстФайла = ТекстШаблона;
		Сообщить("Создан файл хука: " + ПутьКPrecommit);
	КонецЕсли;
	
	ТекстФайла = СтрЗаменить(ТекстФайла, "{appname}", ИмяПриложения);
	ТекстФайла = СтрЗаменить(ТекстФайла, "{repo}", КаталогРепозитория);
	ТекстФайла = СтрЗаменить(ТекстФайла, "{in_file}", ПутьКФайлуПоддержки);
	ТекстФайла = СтрЗаменить(ТекстФайла, "{out_file}", ПутьКНовомуФайлуПоддержки);
	ТекстФайла = СтрЗаменить(ТекстФайла, "{dump_file}", ПутьКФайлуДампа);
	ТекстФайла = СтрЗаменить(ТекстФайла, "{dump_cache}", ПутьКФайлуКэшаИдентификаторов);
	
	ЗаписьТекста = Новый ЗаписьТекста(ПутьКPrecommit, КодировкаТекста.UTF8NoBOM, Символы.ПС, Ложь, Символы.ПС);
	ЗаписьТекста.Записать(ТекстФайла);
	ЗаписьТекста.Закрыть();

	Сообщить("Хук pre-commit установлен");

	СисИнфо = Новый СистемнаяИнформация;
	ЭтоWindows = Найти(НРег(СисИнфо.ВерсияОС), "windows") > 0;
	Если НЕ ЭтоWindows Тогда
		ЗапуститьПриложение("chmod +x " + ПутьКPrecommit);
	КонецЕсли;

КонецПроцедуры