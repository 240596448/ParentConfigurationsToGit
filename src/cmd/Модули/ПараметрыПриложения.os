#Использовать logos

Перем Лог;

Функция Имя() Экспорт
	
	Возврат "ParentConfigConverter";
	
КонецФункции

Функция Версия() Экспорт
	
	Возврат "1.0.0";
	
КонецФункции

Функция ИмяЛога() Экспорт

	Возврат "oscript.app.parentconfig";

КонецФункции

Функция Лог() Экспорт
	
	Если Лог = Неопределено Тогда
		Лог = Логирование.ПолучитьЛог(ИмяЛога());
	КонецЕсли;
	
	Возврат Лог;
	
КонецФункции

Функция ПутьКШаблонам() Экспорт

	Возврат ОбъединитьПути(СтартовыйСценарий().Каталог, "..", "templates");

КонецФункции
