﻿
Процедура ПриУстановкеНовогоКода(СтандартнаяОбработка, Префикс)
	Префикс = СокрЛП(Владелец.Код) + "_П";
КонецПроцедуры


Процедура ПроверитьДублиПоСтрокеИКолонке(Отказ)
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ РАЗЛИЧНЫЕ
		|	ЭД_Показатели.Ссылка КАК Ссылка,
		|	ЭД_Показатели.Код КАК Код
		|ИЗ
		|	Справочник.ЭД_Показатели КАК ЭД_Показатели
		|ГДЕ
		|	ЭД_Показатели.Ссылка <> &Ссылка
		|	И ЭД_Показатели.КолонкаЭД = &КолонкаЭД
		|	И ЭД_Показатели.СтрокаЭД = &СтрокаЭД";
	
	Запрос.УстановитьПараметр("Ссылка", 	Ссылка);
	Запрос.УстановитьПараметр("СтрокаЭД", 	СтрокаЭД);
	Запрос.УстановитьПараметр("КолонкаЭД", 	КолонкаЭД);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Выборка = РезультатЗапроса.Выбрать();
	
	СуществующиеПоказатели = "";
	
	Пока Выборка.Следующий() Цикл
		СуществующиеПоказатели = СуществующиеПоказатели + Выборка.Код + ", ";
	КонецЦикла;
	
	Если СуществующиеПоказатели <> "" Тогда
		Отказ = Истина;
		СуществующиеПоказатели = Лев(СуществующиеПоказатели, СтрДлина(СуществующиеПоказатели) - 2);
		Сообщить("Уже существуют показатели со строкой """ + СтрокаЭД +  """ и колонкой """ + КолонкаЭД + """ с кодами: " + СуществующиеПоказатели, СтатусСообщения.Важное); 
	КонецЕсли;	
	
КонецПроцедуры	


Процедура ПередЗаписью(Отказ)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;    	
	
	ПроверитьДублиПоСтрокеИКолонке(Отказ);
	
	
КонецПроцедуры
