Функция ПрочитатьФайлВТекст(ИмяФайла) Экспорт
	ЧтениеТекста = Новый ЧтениеТекста(ИмяФайла, КодировкаТекста.UTF8);
	Текст = ЧтениеТекста.Прочитать();
	ЧтениеТекста.Закрыть();
	Возврат Текст;
КонецФункции

Процедура ЗаписатьТекстВФайл(ИмяФайла, Текст) Экспорт
	
	ЗаписьТекста = Новый ЗаписьТекста(ИмяФайла, КодировкаТекста.UTF8NoBOM);
	ЗаписьТекста.Записать(Текст);
	ЗаписьТекста.Закрыть();

КонецПроцедуры
