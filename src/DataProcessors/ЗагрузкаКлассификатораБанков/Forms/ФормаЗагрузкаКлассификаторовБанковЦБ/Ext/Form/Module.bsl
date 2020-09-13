﻿
&НаКлиенте
Процедура ОбновитьКлассификаторы(Команда)
	
	ОбновитьКлассификаторыНаСервере();
	
	Элементы.Список.Обновить();
	
КонецПроцедуры

&НаСервереБезКонтекста
Процедура ОбновитьКлассификаторыНаСервере()
	
	Если Метаданные.Обработки.Найти("ЗагрузкаКлассификатораБанков") <> Неопределено Тогда
		Обработки["ЗагрузкаКлассификатораБанков"].ЗагрузитьКлассификаторыБанковЦБИзФайла();
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура СписокПередНачаломДобавления(Элемент, Отказ, Копирование, Родитель, Группа, Параметр)
	Отказ = Истина;
КонецПроцедуры
