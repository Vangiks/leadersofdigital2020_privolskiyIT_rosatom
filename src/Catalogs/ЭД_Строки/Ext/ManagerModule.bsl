﻿
Процедура ОбработкаПолученияПредставления(Данные, Представление, СтандартнаяОбработка)
	//СтандартнаяОбработка = Ложь;
	//Представление = Данные.Ссылка.Наименование + " (";
	//Для Каждого ТекСтрока Из Данные.Ссылка.Аналитики Цикл
	//	
	//	Представление = Представление + ТекСтрока.Аналитика.Наименование + ", ";
	//	
	//КонецЦикла;
	//Представление = Лев(Представление, СтрДлина(Представление)-2) + ")";
КонецПроцедуры
