﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2020, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	БольшеНеПоказывать = Ложь;
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	СистемнаяИнформация = Новый СистемнаяИнформация;
	
	Если СтрНайти(СистемнаяИнформация.ИнформацияПрограммыПросмотра, "Firefox") <> 0 Тогда
		Элементы.Дополнения.ТекущаяСтраница = Элементы.MozillaFireFox;
	Иначе
		Элементы.Дополнения.ТекущаяСтраница = Элементы.Пустая;
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ПродолжитьВыполнить(Команда)
	
	Если БольшеНеПоказывать = Истина Тогда
		ОбщегоНазначенияВызовСервера.ХранилищеОбщихНастроекСохранить(
			"НастройкиПрограммы", "ПоказыватьПодсказкиПриРедактированииФайлов", Ложь,,, Истина);
	КонецЕсли;
	
	Закрыть(Истина);
	
КонецПроцедуры

#КонецОбласти
