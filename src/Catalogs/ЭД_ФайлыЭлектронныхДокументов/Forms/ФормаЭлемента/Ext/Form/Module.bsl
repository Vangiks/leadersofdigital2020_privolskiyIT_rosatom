﻿
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	Если ТипЗнч(Параметры.ДополнительныеПараметры) = Тип("Структура") Тогда
		Если Параметры.ДополнительныеПараметры.Свойство("ЭлектронныйДокумент") Тогда
			
			Объект.ЭлектронныйДокумент = Параметры.ДополнительныеПараметры.ЭлектронныйДокумент;
			
		КонецЕсли;
	КонецЕсли;	 
КонецПроцедуры
