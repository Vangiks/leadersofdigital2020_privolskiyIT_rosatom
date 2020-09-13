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
	
	Если Параметры.ПапкаЭкспорта <> Неопределено Тогда
		ЧтоСохраняем = Параметры.ПапкаЭкспорта;
	КонецЕсли;
	
	Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.ЭлектроннаяПодпись") Тогда
		МодульЭлектроннаяПодпись = ОбщегоНазначения.ОбщийМодуль("ЭлектроннаяПодпись");
		
		РасширениеДляЗашифрованныхФайлов =
			МодульЭлектроннаяПодпись.ПерсональныеНастройки().РасширениеДляЗашифрованныхФайлов;
	Иначе
		РасширениеДляЗашифрованныхФайлов = "p7m";
	КонецЕсли;
	
	ИмяСправочникаХранилищаФайлов       = Параметры.ИмяСправочникаХранилищаФайлов;
	ИмяСправочникаХранилищаВерсийФайлов = Параметры.ИмяСправочникаХранилищаВерсийФайлов;
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	// Установка в качестве папки выгрузки "Мои Документы"
	// папку, используемую для выгрузки последний раз.
	ПапкаДляЭкспорта = РаботаСФайламиСлужебныйКлиент.КаталогВыгрузки();
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура ПапкаДляЭкспортаОткрытие(Элемент, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	Если Не ПустаяСтрока(Элемент.ТекстРедактирования) Тогда
		ФайловаяСистемаКлиент.ОткрытьПроводник(Элемент.ТекстРедактирования);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПапкаДляЭкспортаНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	// Открытие окна выбора папки сохранения.
	СтандартнаяОбработка = Ложь;
	ВыборФайла = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.ВыборКаталога);
	ВыборФайла.МножественныйВыбор = Ложь;
	ВыборФайла.Каталог = Элемент.ТекстРедактирования;
	Если ВыборФайла.Выбрать() Тогда
		ПапкаДляЭкспорта = ВыборФайла.Каталог + ПолучитьРазделительПути();
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура СохранитьПапку()
	
	Если ПустаяСтрока(ПапкаДляЭкспорта) Или ПапкаДляЭкспорта = ПолучитьРазделительПути() Тогда
		ПоказатьПредупреждение(, НСтр("ru = 'Необходимо указать папку.'"));
		Возврат;
	КонецЕсли;
	
	Если НЕ СтрЗаканчиваетсяНа(ПапкаДляЭкспорта, ПолучитьРазделительПути()) Тогда
		ПапкаДляЭкспорта = ПапкаДляЭкспорта + ПолучитьРазделительПути();
	КонецЕсли;
	
	// Проверим - каталог выгрузки существует? если нет - создадим.
	КаталогВыгрузки = Новый Файл(ПапкаДляЭкспорта);
	
	Если Не КаталогВыгрузки.Существует() Тогда
		ПоказатьПредупреждение(, СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Папка ""%1"" не найдена.
			           |Выберите другую папку.'"),
			ПапкаДляЭкспорта));
		Возврат;
	КонецЕсли;
	
	ПапкаДляЭкспортаПолная = ПапкаДляЭкспорта + Строка(ЧтоСохраняем) + ПолучитьРазделительПути();
	Если ТранслитерироватьИменаПапокИФайлов Тогда
		ПапкаДляЭкспортаПолная = СтроковыеФункцииКлиент.СтрокаЛатиницей(ПапкаДляЭкспортаПолная);
	КонецЕсли;
	
	// Если выгружаемая папка не существует, ее следует создать.
	КаталогВыгрузки = Новый Файл(ПапкаДляЭкспортаПолная);
	Если Не КаталогВыгрузки.Существует() Тогда
		ТекстОшибки = "";
		Попытка
			СоздатьКаталог(ПапкаДляЭкспортаПолная);
			Если Не КаталогВыгрузки.Существует() Тогда
				ВызватьИсключение НСтр("ru = 'После успешного создания подпапка не найдена.'");
			КонецЕсли;
		Исключение
			ИнформацияОбОшибке = ИнформацияОбОшибке();
			ТекстОшибки = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru = 'Не удалось создать подпапку ""%1"" в папке ""%2"" по причине:
				           |%3'"),
				Строка(ЧтоСохраняем),
				ПапкаДляЭкспорта,
				КраткоеПредставлениеОшибки(ИнформацияОбОшибке));
		КонецПопытки;
		Если ТекстОшибки <> "" Тогда
			ПоказатьПредупреждение(, ТекстОшибки);
			Возврат;
		КонецЕсли;
	КонецЕсли;
	
	// Получим список выгружаемых файлов.
	СформироватьДеревоФайлов(ЧтоСохраняем);
	
	// А теперь начнем выгрузку
	Обработчик = Новый ОписаниеОповещения("СохранитьПапкуЗавершение", ЭтотОбъект);
	ОбойтиДеревоФайлов(Обработчик, ДеревоФайлов, ПапкаДляЭкспортаПолная, ЧтоСохраняем, Неопределено);
КонецПроцедуры

&НаКлиенте
Процедура СохранитьПапкуЗавершение(Результат, ПараметрыВыполнения) Экспорт
	Если Результат.Успех = Истина Тогда
		СохраняемыйПуть = ПапкаДляЭкспорта;
		ОбщегоНазначенияВызовСервера.ХранилищеОбщихНастроекСохранить("ИмяПапкиВыгрузки", "ИмяПапкиВыгрузки",  СохраняемыйПуть);
		
		ПоказатьОповещениеПользователя(НСтр("ru = 'Экспорт папки'"),,
		             СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
		               НСтр("ru = 'Успешно завершен экспорт папки ""%1""
		                          |в папку на диске ""%2"".'"),
		               Строка(ЧтоСохраняем), Строка(ПапкаДляЭкспорта) ) );
		
		Закрыть();
	КонецЕсли;
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура СформироватьДеревоФайлов(ПапкаРодитель)
	
	Запрос = Новый Запрос;
	ТекстЗапроса =
	"ВЫБРАТЬ РАЗРЕШЕННЫЕ
	|	Файлы.ВладелецФайла КАК Папка,
	|	ВЫРАЗИТЬ(Файлы.ВладелецФайла КАК Справочник.ПапкиФайлов).Наименование КАК НаименованиеПапки,
	|	&ТекущаяВерсия КАК ТекущаяВерсия,
	|	Файлы.Наименование КАК ПолноеНаименование,
	|	Файлы.Расширение КАК Расширение,
	|	Файлы.Размер КАК Размер,
	|	Файлы.ДатаМодификацииУниверсальная КАК ДатаМодификацииУниверсальная,
	|	Файлы.Ссылка КАК Ссылка,
	|	Файлы.ПометкаУдаления КАК ПометкаУдаления,
	|	Файлы.Зашифрован КАК Зашифрован
	|ИЗ
	|	Справочник.Файлы КАК Файлы
	|ГДЕ
	|	Файлы.ВладелецФайла В ИЕРАРХИИ(&Ссылка)
	|	И Файлы.ПометкаУдаления = ЛОЖЬ
	|ИТОГИ ПО
	|	Папка ИЕРАРХИЯ";
	Запрос.Параметры.Вставить("Ссылка", ПапкаРодитель);
	
	Если Не ПустаяСтрока(ИмяСправочникаХранилищаФайлов) Тогда
		
		ТекстЗапроса = СтрЗаменить(ТекстЗапроса, "Файлы", ИмяСправочникаХранилищаФайлов);
		ТекстЗапроса = СтрЗаменить(ТекстЗапроса, "&ТекущаяВерсия", ИмяСправочникаХранилищаФайлов + ".Ссылка");
		ТекстЗапроса = СтрЗаменить(ТекстЗапроса, "ВладелецФайла", "Родитель");
		ТекстЗапроса = СтрЗаменить(ТекстЗапроса, "ПапкиФайлов", ИмяСправочникаХранилищаФайлов);
		
	Иначе
		
		ВыборТекущейВерсии = "ВЫБОР
		|		КОГДА Файлы.ТекущаяВерсия = ЗНАЧЕНИЕ(Справочник.ВерсииФайлов.ПустаяСсылка)
		|			ТОГДА Файлы.Ссылка
		|		ИНАЧЕ ЕстьNull(Файлы.ТекущаяВерсия, ЗНАЧЕНИЕ(Справочник.ВерсииФайлов.ПустаяСсылка))
		|	КОНЕЦ";
		
		ТекстЗапроса = СтрЗаменить(ТекстЗапроса, "&ТекущаяВерсия", ВыборТекущейВерсии);
		
	КонецЕсли;
	
	Запрос.Текст = ТекстЗапроса;
	Результат = Запрос.Выполнить();
	
	ТаблицаВыгрузки = Результат.Выгрузить(ОбходРезультатаЗапроса.ПоГруппировкамСИерархией);
	Если ТранслитерироватьИменаПапокИФайлов И ТаблицаВыгрузки.Строки.Количество() > 0 Тогда
		КорневаяПапкаДляВыгрузки = ТаблицаВыгрузки.Строки[0];
		КорневаяПапкаДляВыгрузки.НаименованиеПапки = СтроковыеФункции.СтрокаЛатиницей(КорневаяПапкаДляВыгрузки.НаименованиеПапки);
		КорневаяПапкаДляВыгрузки.ПолноеНаименование = СтроковыеФункции.СтрокаЛатиницей(КорневаяПапкаДляВыгрузки.ПолноеНаименование);
		КорневаяПапкаДляВыгрузки.Расширение = СтроковыеФункции.СтрокаЛатиницей(КорневаяПапкаДляВыгрузки.Расширение);
		ИзменитьИменаФайловИПапок(КорневаяПапкаДляВыгрузки);
	КонецЕсли;
	
	ЗначениеВРеквизитФормы(ТаблицаВыгрузки, "ДеревоФайлов");
	
КонецПроцедуры

// Рекурсивная функция, которая собственно и выгружает файлы на локальный диск.
//
// Параметры:
//   ОбработчикРезультата - ОписаниеОповещения
//                        - Структура
//                        - Неопределено - описание процедуры, принимающей результат
//                          работы метода.
//   ТаблицаФайлов - ДанныеФормыДерево
//                 - ДанныеФормыЭлементДерева - дерево значений с выгружаемыми файлами.
//   БазовыйКаталогСохранения - Строка - строка с именем папки, в которую сохраняются файлы.
//                 В ней воссоздается структура папок (как в дереве файлов)
//                 при необходимости.
//   РодительскаяПапка - СправочникСсылка.ПапкиФайлов - что сохраняем.
//   ОбщиеПараметры - Структура:
//       * ДляВсехФайлов - Булево -
//                 Истина: пользователь выбрал действие при перезаписи файла и
//                 установил флажок "Для всех". Больше вопросов не задаем.
//                 Ложь: в каждом случае существования файла на диске, с тем же
//                 именем, что и в информационной базе будем задавать вопрос.
//       * БазовоеДействие - КодВозвратаДиалога -
//                 при выполнении одного действия для всех конфликтов при
//                 записи файла (параметр ДляВсехФайлов = Истина) выполняется
//                 действие, заданное этим параметром).
//                 .Да - перезаписать.
//                 .Пропустить - пропустить файл.
//                 .Прервать - прервать выгрузку.
//
// Возвращаемое значение: 
//   Структура:
//       * Успех - Булево - Истина - можно продолжать выгрузку / выгрузка завершена успешно.
//                         Ложь   - действие завершено с ошибками / выгрузка завершена с ошибками.
//
&НаКлиенте
Процедура ОбойтиДеревоФайлов(ОбработчикРезультата, ТаблицаФайлов, БазовыйКаталогСохранения, РодительскаяПапка, ОбщиеПараметры)
	
	Если ОбщиеПараметры = Неопределено Тогда
		ОбщиеПараметры = Новый Структура;
		ОбщиеПараметры.Вставить("БазовоеДействие", КодВозвратаДиалога.Пропустить);
		ОбщиеПараметры.Вставить("ДляВсехФайлов", Ложь);
		ОбщиеПараметры.Вставить("ЕщеНеВстретилиВыгружаемуюПапку", Истина);
	КонецЕсли;
	
	ПараметрыВыполнения = ПараметрыВыполнения(
		ОбработчикРезультата,
		ТаблицаФайлов,
		БазовыйКаталогСохранения,
		РодительскаяПапка,
		ОбщиеПараметры);
	
	ОбработчикЗавершения = Новый ОписаниеОповещения("ОбойтиДеревоФайлов2", ЭтотОбъект);
	РаботаСФайламиСлужебныйКлиент.ЗарегистрироватьОбработчикЗавершения(ПараметрыВыполнения, ОбработчикЗавершения);
	
	// Переменные.
	ПараметрыВыполнения.Вставить("ЗаписьФайла", Неопределено);
	
	// Запуск цикла.
	ОбойтиДеревоФайловЗапускЦикла(ПараметрыВыполнения);
КонецПроцедуры


&НаКлиенте
Функция ПараметрыВыполнения(Знач ОбработчикРезультата, Знач ТаблицаФайлов, Знач БазовыйКаталогСохранения, Знач РодительскаяПапка, Знач ОбщиеПараметры)
	ПараметрыВыполнения = Новый Структура;
	ПараметрыВыполнения.Вставить("ОбработчикРезультата", ОбработчикРезультата);
	ПараметрыВыполнения.Вставить("ТаблицаФайлов", ТаблицаФайлов);
	ПараметрыВыполнения.Вставить("БазовыйКаталогСохранения", БазовыйКаталогСохранения);
	ПараметрыВыполнения.Вставить("РодительскаяПапка", РодительскаяПапка);
	ПараметрыВыполнения.Вставить("ОбщиеПараметры", ОбщиеПараметры);
	
	// Параметры результата.
	ПараметрыВыполнения.Вставить("Успех", Ложь);
	
	// Параметры для цикла.
	ПараметрыВыполнения.Вставить("Элементы", ПараметрыВыполнения.ТаблицаФайлов.ПолучитьЭлементы());
	ПараметрыВыполнения.Вставить("ВГраница", ПараметрыВыполнения.Элементы.Количество()-1);
	ПараметрыВыполнения.Вставить("Индекс",   -1);
	ПараметрыВыполнения.Вставить("ТребуетсяЗапускЦикла", Истина);
	Возврат ПараметрыВыполнения
КонецФункции


&НаКлиенте
Процедура ОбойтиДеревоФайловЗапускЦикла(ПараметрыВыполнения)
	Если ПараметрыВыполнения.ТребуетсяЗапускЦикла Тогда
		Если РаботаСФайламиСлужебныйКлиент.БлокирующаяФормаОткрыта(ПараметрыВыполнения) Тогда
			Возврат; // Был открыт еще один диалог - перезапуск цикла не нужен.
		КонецЕсли;
		ПараметрыВыполнения.Индекс = ПараметрыВыполнения.Индекс + 1;
		ПараметрыВыполнения.ТребуетсяЗапускЦикла = Ложь;
	Иначе
		Возврат; // Цикл уже запущен.
	КонецЕсли;
	
	Для Индекс = ПараметрыВыполнения.Индекс По ПараметрыВыполнения.ВГраница Цикл
		ПараметрыВыполнения.ЗаписьФайла = ПараметрыВыполнения.Элементы[Индекс];
		ПараметрыВыполнения.Индекс = Индекс;
		ОбойтиДеревоФайлов1(ПараметрыВыполнения);
		Если РаботаСФайламиСлужебныйКлиент.БлокирующаяФормаОткрыта(ПараметрыВыполнения) Тогда
			Возврат; // Пауза цикла. Стек очищается.
		КонецЕсли;
	КонецЦикла;
	
	ПараметрыВыполнения.Успех = Истина;
	РаботаСФайламиСлужебныйКлиент.ВернутьРезультат(ПараметрыВыполнения.ОбработчикРезультата, ПараметрыВыполнения);
КонецПроцедуры

&НаКлиенте
Процедура ОбойтиДеревоФайлов1(ПараметрыВыполнения)
	Если ПараметрыВыполнения.ОбщиеПараметры.ЕщеНеВстретилиВыгружаемуюПапку = Истина Тогда
		Если ПараметрыВыполнения.ЗаписьФайла.Папка = ЧтоСохраняем Тогда
			ПараметрыВыполнения.ОбщиеПараметры.ЕщеНеВстретилиВыгружаемуюПапку = Ложь;
		КонецЕсли;
	КонецЕсли;
	
	Если ПараметрыВыполнения.ОбщиеПараметры.ЕщеНеВстретилиВыгружаемуюПапку = Истина Тогда
		
		ОбработчикЗавершения = Новый ОписаниеОповещения("ОбойтиДеревоФайлов2", ЭтотОбъект);
		РаботаСФайламиСлужебныйКлиент.ЗарегистрироватьОбработчикЗавершения(ПараметрыВыполнения, ОбработчикЗавершения);
		
		ОбойтиДеревоФайлов(
			ПараметрыВыполнения,
			ПараметрыВыполнения.ЗаписьФайла,
			ПараметрыВыполнения.БазовыйКаталогСохранения,
			ПараметрыВыполнения.ЗаписьФайла.Папка,
			ПараметрыВыполнения.ОбщиеПараметры);
		
		Если РаботаСФайламиСлужебныйКлиент.БлокирующаяФормаОткрыта(ПараметрыВыполнения) Тогда
			Возврат; // Пауза цикла. Стек очищается.
		КонецЕсли;
		
		ОбойтиДеревоФайлов2(ПараметрыВыполнения.АсинхронныйДиалог.РезультатКогдаНеОткрыт, ПараметрыВыполнения);
		Возврат;
	КонецЕсли;
	
	ОбойтиДеревоФайлов3(ПараметрыВыполнения);
КонецПроцедуры

&НаКлиенте
Процедура ОбойтиДеревоФайлов2(Результат, ПараметрыВыполнения) Экспорт
	Если РаботаСФайламиСлужебныйКлиент.БлокирующаяФормаОткрыта(ПараметрыВыполнения) Тогда
		ПараметрыВыполнения.ТребуетсяЗапускЦикла = Истина;
		РаботаСФайламиСлужебныйКлиент.УстановитьПризнакБлокирующейФормы(ПараметрыВыполнения, Ложь);
	КонецЕсли;
	
	Если Результат.Успех <> Истина Тогда
		ПараметрыВыполнения.Успех = Ложь;
		ПараметрыВыполнения.ТребуетсяЗапускЦикла = Ложь; // Цикл перезапускать не требуется.
		РаботаСФайламиСлужебныйКлиент.ВернутьРезультат(ПараметрыВыполнения.ОбработчикРезультата, ПараметрыВыполнения);
		Возврат;
	КонецЕсли;
	
	ОбойтиДеревоФайловЗапускЦикла(ПараметрыВыполнения);
КонецПроцедуры

&НаКлиенте
Процедура ОбойтиДеревоФайлов3(ПараметрыВыполнения)
	ПараметрыВыполнения.Вставить("БазовыйКаталогСохраненияФайла", ПараметрыВыполнения.БазовыйКаталогСохранения);
	Если ПараметрыВыполнения.ЗаписьФайла.Папка <> ЧтоСохраняем
		И ПараметрыВыполнения.ЗаписьФайла.ТекущаяВерсия = Неопределено
		И ПараметрыВыполнения.ЗаписьФайла.Папка <> ПараметрыВыполнения.РодительскаяПапка Тогда
		ПараметрыВыполнения.БазовыйКаталогСохраненияФайла = ПараметрыВыполнения.БазовыйКаталогСохраненияФайла
			+ ПараметрыВыполнения.ЗаписьФайла.НаименованиеПапки	+ ПолучитьРазделительПути();
	КонецЕсли;
	
	Папка = Новый Файл(ПараметрыВыполнения.БазовыйКаталогСохраненияФайла);
	Если Не Папка.Существует() Тогда
		СоздатьПодкаталог(ПараметрыВыполнения); 
		Возврат;
	КонецЕсли;
	
	ОбойтиДеревоФайлов6(ПараметрыВыполнения);
КонецПроцедуры

&НаКлиенте
Процедура СоздатьПодкаталог(ПараметрыВыполнения)
	ТекстОшибки = "";
	Попытка
		СоздатьКаталог(ПараметрыВыполнения.БазовыйКаталогСохраненияФайла);
	Исключение
		ТекстОшибки = НСтр("ru = 'Ошибка создания папки ""%1"":'");
		ТекстОшибки = СтрЗаменить(ТекстОшибки, "%1", ПараметрыВыполнения.БазовыйКаталогСохраненияФайла);
		ТекстОшибки = ТекстОшибки + Символы.ПС + Символы.ПС + КраткоеПредставлениеОшибки(ИнформацияОбОшибке());
	КонецПопытки;
	
	Если ТекстОшибки <> "" Тогда
		РаботаСФайламиСлужебныйКлиент.УстановитьПризнакБлокирующейФормы(ПараметрыВыполнения, Истина);
		Обработчик = Новый ОписаниеОповещения("ОбойтиДеревоФайлов5", ЭтотОбъект, ПараметрыВыполнения);
		ПоказатьВопрос(Обработчик, ТекстОшибки, РежимДиалогаВопрос.ПрерватьПовторитьПропустить, , КодВозвратаДиалога.Повторить);
		Возврат;
	КонецЕсли;
	
	ОбойтиДеревоФайлов6(ПараметрыВыполнения);
КонецПроцедуры

&НаКлиенте
Процедура ОбойтиДеревоФайлов5(Ответ, ПараметрыВыполнения) Экспорт
	Если РаботаСФайламиСлужебныйКлиент.БлокирующаяФормаОткрыта(ПараметрыВыполнения) Тогда
		ПараметрыВыполнения.ТребуетсяЗапускЦикла = Истина;
		РаботаСФайламиСлужебныйКлиент.УстановитьПризнакБлокирующейФормы(ПараметрыВыполнения, Ложь);
	КонецЕсли;
	
	Если Ответ = КодВозвратаДиалога.Прервать Тогда
		// Просто выйдем с ошибкой
		ПараметрыВыполнения.Успех = Ложь;
		ПараметрыВыполнения.ТребуетсяЗапускЦикла = Ложь; // Цикл перезапускать не требуется.
		РаботаСФайламиСлужебныйКлиент.ВернутьРезультат(ПараметрыВыполнения.ОбработчикРезультата, ПараметрыВыполнения);
		Возврат;
	ИначеЕсли Ответ = КодВозвратаДиалога.Пропустить Тогда
		// Пропустим данную ветку дерева и пойдем дальше.
		ПараметрыВыполнения.Успех = Истина;
		ПараметрыВыполнения.ТребуетсяЗапускЦикла = Ложь; // Цикл перезапускать не требуется.
		РаботаСФайламиСлужебныйКлиент.ВернутьРезультат(ПараметрыВыполнения.ОбработчикРезультата, ПараметрыВыполнения);
		Возврат;
	КонецЕсли;
	
	// Попробуем повторить создание папки.
	СоздатьПодкаталог(ПараметрыВыполнения);
КонецПроцедуры

&НаКлиенте
Процедура ОбойтиДеревоФайлов6(ПараметрыВыполнения)
	// Только в том случае, если в этой папке есть хоть один файл.
	ДочерниеЭлементы = ПараметрыВыполнения.ЗаписьФайла.ПолучитьЭлементы();
	Если ДочерниеЭлементы.Количество() > 0 Тогда
		
		ОбработчикЗавершения = Новый ОписаниеОповещения("ОбойтиДеревоФайлов7", ЭтотОбъект);
		РаботаСФайламиСлужебныйКлиент.ЗарегистрироватьОбработчикЗавершения(ПараметрыВыполнения, ОбработчикЗавершения);
		
		ОбойтиДеревоФайлов(
			ПараметрыВыполнения,
			ПараметрыВыполнения.ЗаписьФайла,
			ПараметрыВыполнения.БазовыйКаталогСохраненияФайла,
			ПараметрыВыполнения.ЗаписьФайла.Папка,
			ПараметрыВыполнения.ОбщиеПараметры);
		
		Если РаботаСФайламиСлужебныйКлиент.БлокирующаяФормаОткрыта(ПараметрыВыполнения) Тогда
			Возврат; // Пауза цикла. Стек очищается.
		КонецЕсли;
		
		ОбойтиДеревоФайлов7(ПараметрыВыполнения.АсинхронныйДиалог.РезультатКогдаНеОткрыт, ПараметрыВыполнения);
		Возврат;
	КонецЕсли;
	
	ОбойтиДеревоФайлов8(ПараметрыВыполнения);
КонецПроцедуры

&НаКлиенте
Процедура ОбойтиДеревоФайлов7(Результат, ПараметрыВыполнения) Экспорт
	Если РаботаСФайламиСлужебныйКлиент.БлокирующаяФормаОткрыта(ПараметрыВыполнения) Тогда
		ПараметрыВыполнения.ТребуетсяЗапускЦикла = Истина;
		РаботаСФайламиСлужебныйКлиент.УстановитьПризнакБлокирующейФормы(ПараметрыВыполнения, Ложь);
	КонецЕсли;
	
	Если Результат.Успех <> Истина Тогда
		ПараметрыВыполнения.Успех = Ложь;
		ПараметрыВыполнения.ТребуетсяЗапускЦикла = Ложь;
		РаботаСФайламиСлужебныйКлиент.ВернутьРезультат(ПараметрыВыполнения.ОбработчикРезультата, ПараметрыВыполнения);
		Возврат;
	КонецЕсли;
	
	// Продолжение обработки элемента.
	ОбойтиДеревоФайлов8(ПараметрыВыполнения);
	
	// Перезапуск цикла если был открыт асинхронный диалог.
	ОбойтиДеревоФайловЗапускЦикла(ПараметрыВыполнения);
КонецПроцедуры

&НаКлиенте
Процедура ОбойтиДеревоФайлов8(ПараметрыВыполнения)
	Если (ПараметрыВыполнения.ЗаписьФайла.ТекущаяВерсия <> Неопределено
		И ПараметрыВыполнения.ЗаписьФайла.ТекущаяВерсия.Пустая()) Или ПараметрыВыполнения.ЗаписьФайла.ТекущаяВерсия = Неопределено Тогда
		// Это элемент справочника Файлы без файла - пропустим.
		Возврат;
	КонецЕсли;
	
	// Пишем файл в базовый каталог.
	ПараметрыВыполнения.Вставить("ИмяФайлаСРасширением", Неопределено);
	ПараметрыВыполнения.ИмяФайлаСРасширением = ОбщегоНазначенияКлиентСервер.ПолучитьИмяСРасширением(
		ПараметрыВыполнения.ЗаписьФайла.ПолноеНаименование,
		ПараметрыВыполнения.ЗаписьФайла.Расширение);
	
	Если ПараметрыВыполнения.ЗаписьФайла.Зашифрован Тогда
		ПараметрыВыполнения.ИмяФайлаСРасширением = ПараметрыВыполнения.ИмяФайлаСРасширением + "." + РасширениеДляЗашифрованныхФайлов;
	КонецЕсли;
	ПараметрыВыполнения.Вставить("ПолноеИмяФайла", ПараметрыВыполнения.БазовыйКаталогСохраненияФайла + ПараметрыВыполнения.ИмяФайлаСРасширением);
	
	ПараметрыВыполнения.Вставить("Результат", Неопределено);
	ОбойтиДеревоФайлов9(ПараметрыВыполнения);
КонецПроцедуры

&НаКлиенте
Процедура ОбойтиДеревоФайлов9(ПараметрыВыполнения)
	ПараметрыВыполнения.Вставить("ФайлНаДиске", Новый Файл(ПараметрыВыполнения.ПолноеИмяФайла));
	Если ПараметрыВыполнения.ФайлНаДиске.Существует() И ПараметрыВыполнения.ФайлНаДиске.ЭтоКаталог() Тогда
		ТекстВопроса = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Вместо файла
			           |""%1""
			           |существует папка с таким же именем.
			           |
			           |Повторить экспорт этого файла?'"),
			ПараметрыВыполнения.ПолноеИмяФайла);
		РаботаСФайламиСлужебныйКлиент.УстановитьПризнакБлокирующейФормы(ПараметрыВыполнения, Истина);
		Обработчик = Новый ОписаниеОповещения("ОбойтиДеревоФайлов10", ЭтотОбъект, ПараметрыВыполнения);
		ПоказатьВопрос(Обработчик, ТекстВопроса, РежимДиалогаВопрос.ПовторитьОтмена, , КодВозвратаДиалога.Отмена);
		Возврат;
	КонецЕсли;
	
	// Файла нет - идем дальше
	ПараметрыВыполнения.Результат = КодВозвратаДиалога.Повторить;
	ОбойтиДеревоФайлов11(ПараметрыВыполнения);
КонецПроцедуры

&НаКлиенте
Процедура ОбойтиДеревоФайлов10(Ответ, ПараметрыВыполнения) Экспорт
	Если РаботаСФайламиСлужебныйКлиент.БлокирующаяФормаОткрыта(ПараметрыВыполнения) Тогда
		ПараметрыВыполнения.ТребуетсяЗапускЦикла = Истина;
		РаботаСФайламиСлужебныйКлиент.УстановитьПризнакБлокирующейФормы(ПараметрыВыполнения, Ложь);
	КонецЕсли;
	
	Если Ответ = КодВозвратаДиалога.Повторить Тогда
		// Данный файл игнорируем
		ОбойтиДеревоФайлов9(ПараметрыВыполнения);
		Возврат;
	КонецЕсли;
	
	// Продолжение обработки элемента.
	ПараметрыВыполнения.Результат = КодВозвратаДиалога.Отмена;
	ОбойтиДеревоФайлов11(ПараметрыВыполнения);
	
	// Перезапуск цикла если был открыт асинхронный диалог.
	ОбойтиДеревоФайловЗапускЦикла(ПараметрыВыполнения);
КонецПроцедуры

&НаКлиенте
Процедура ОбойтиДеревоФайлов11(ПараметрыВыполнения)
	Если ПараметрыВыполнения.Результат = КодВозвратаДиалога.Отмена Тогда
		// Игнорируем файл с именем как у папки.
		Возврат;
	КонецЕсли;
	
	ПараметрыВыполнения.Результат = КодВозвратаДиалога.Нет;
	
	// Спросим, а что делать с текущим файлом.
	Если ПараметрыВыполнения.ФайлНаДиске.Существует() Тогда
		
		// Если файл только для чтения и время изменения меньше, чем в информационной базе - просто перепишем.
		Если  ПараметрыВыполнения.ФайлНаДиске.ПолучитьТолькоЧтение()
			И ПараметрыВыполнения.ФайлНаДиске.ПолучитьУниверсальноеВремяИзменения() <= ПараметрыВыполнения.ЗаписьФайла.ДатаМодификацииУниверсальная Тогда
			ПараметрыВыполнения.Результат = КодВозвратаДиалога.Да;
		Иначе
			Если Не ПараметрыВыполнения.ОбщиеПараметры.ДляВсехФайлов Тогда
				ТекстСообщения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
					НСтр("ru = 'В папке ""%1""
					           |существует файл ""%2""
					           |размер существующего файла = %3 байт, дата изменения %4.
					           |размер сохраняемого файла = %5 байт, дата изменения %6.
					           |
					           |Заменить существующий файл файлом из хранилища файлов?'"),
					ПараметрыВыполнения.БазовыйКаталогСохраненияФайла,
					ПараметрыВыполнения.ИмяФайлаСРасширением,
					ПараметрыВыполнения.ФайлНаДиске.Размер(),
					МестноеВремя(ПараметрыВыполнения.ФайлНаДиске.ПолучитьУниверсальноеВремяИзменения()),
					ПараметрыВыполнения.ЗаписьФайла.Размер,
					МестноеВремя(ПараметрыВыполнения.ЗаписьФайла.ДатаМодификацииУниверсальная));
				
				СтруктураПараметров = Новый Структура;
				СтруктураПараметров.Вставить("ТекстСообщения",   ТекстСообщения);
				СтруктураПараметров.Вставить("ПрименитьДляВсех", ПараметрыВыполнения.ОбщиеПараметры.ДляВсехФайлов);
				СтруктураПараметров.Вставить("БазовоеДействие",  Строка(ПараметрыВыполнения.ОбщиеПараметры.БазовоеДействие));
				
				РаботаСФайламиСлужебныйКлиент.УстановитьПризнакБлокирующейФормы(ПараметрыВыполнения, Истина);
				Обработчик = Новый ОписаниеОповещения("ОбойтиДеревоФайлов12", ЭтотОбъект, ПараметрыВыполнения);
				
				ОткрытьФорму("Обработка.РаботаСФайлами.Форма.ФайлСуществует", СтруктураПараметров, , , , , Обработчик);
				Возврат;
			КонецЕсли;
			
			ПараметрыВыполнения.Результат = ПараметрыВыполнения.ОбщиеПараметры.БазовоеДействие;
			ОбойтиДеревоФайлов13(ПараметрыВыполнения);
			Возврат;
		КонецЕсли;
	КонецЕсли;
	
	// Файла нет, спрашивать не будем.
	ПараметрыВыполнения.Результат = КодВозвратаДиалога.Да;
	ОбойтиДеревоФайлов14(ПараметрыВыполнения);
КонецПроцедуры

&НаКлиенте
Процедура ОбойтиДеревоФайлов12(Результат, ПараметрыВыполнения) Экспорт
	Если РаботаСФайламиСлужебныйКлиент.БлокирующаяФормаОткрыта(ПараметрыВыполнения) Тогда
		ПараметрыВыполнения.ТребуетсяЗапускЦикла = Истина;
		РаботаСФайламиСлужебныйКлиент.УстановитьПризнакБлокирующейФормы(ПараметрыВыполнения, Ложь);
	КонецЕсли;
	
	ПараметрыВыполнения.Результат = Результат.КодВозврата;
	ПараметрыВыполнения.ОбщиеПараметры.ДляВсехФайлов = Результат.ПрименитьДляВсех;
	ПараметрыВыполнения.ОбщиеПараметры.БазовоеДействие = ПараметрыВыполнения.Результат;
	
	// Продолжение обработки элемента.
	ОбойтиДеревоФайлов13(ПараметрыВыполнения);
	
	// Перезапуск цикла если был открыт асинхронный диалог.
	ОбойтиДеревоФайловЗапускЦикла(ПараметрыВыполнения);
КонецПроцедуры

&НаКлиенте
Процедура ОбойтиДеревоФайлов13(ПараметрыВыполнения)
	Если ПараметрыВыполнения.Результат = КодВозвратаДиалога.Прервать Тогда
		// Прерываем выгрузку
		ПараметрыВыполнения.Успех = Ложь;
		ПараметрыВыполнения.ТребуетсяЗапускЦикла = Ложь; // Цикл перезапускать не требуется.
		РаботаСФайламиСлужебныйКлиент.ВернутьРезультат(ПараметрыВыполнения.ОбработчикРезультата, ПараметрыВыполнения);
		Возврат;
	ИначеЕсли ПараметрыВыполнения.Результат = КодВозвратаДиалога.Пропустить Тогда
		// Пропускаем этот файл
		Возврат;
	КонецЕсли;
	
	// Если можно - запишем файл в файловую систему.
	Если ПараметрыВыполнения.Результат <> КодВозвратаДиалога.Да Тогда
		Возврат;
	КонецЕсли;
	
	ОбойтиДеревоФайлов14(ПараметрыВыполнения);
КонецПроцедуры

&НаКлиенте
Процедура ОбойтиДеревоФайлов14(ПараметрыВыполнения)
	ПараметрыВыполнения.ФайлНаДиске = Новый Файл(ПараметрыВыполнения.ПолноеИмяФайла);
	Если ПараметрыВыполнения.ФайлНаДиске.Существует() Тогда
		// Снимем флаг R|O для возможности удаления.
		ПараметрыВыполнения.ФайлНаДиске.УстановитьТолькоЧтение(Ложь);
		
		// Всегда удаляем и потом создадим заново.
		ИнформацияОбОшибке = Неопределено;
		Попытка
			УдалитьФайлы(ПараметрыВыполнения.ПолноеИмяФайла);
		Исключение
			ИнформацияОбОшибке = ИнформацияОбОшибке();
		КонецПопытки;
		
		Если ИнформацияОбОшибке <> Неопределено Тогда
			ОбойтиДеревоФайлов15(ИнформацияОбОшибке, ПараметрыВыполнения);
			Возврат;
		КонецЕсли;
	КонецЕсли;
	
	// Запишем файл заново
	АдресФайлаДляОткрытия = РаботаСФайламиСлужебныйВызовСервера.ПолучитьНавигационнуюСсылкуДляОткрытия(
		ПараметрыВыполнения.ЗаписьФайла.ТекущаяВерсия,
		УникальныйИдентификатор);
	
	Попытка
		ПолучаемыеФайлы  = Новый Массив;
		ПередаваемыйФайл = Новый ОписаниеПередаваемогоФайла();
		ПолученныеФайлы  = Новый Массив;// Массив Из Файл

		ПередаваемыйФайл.Хранение = АдресФайлаДляОткрытия;
		ПередаваемыйФайл.Имя      = ПараметрыВыполнения.ПолноеИмяФайла;
		ПолучаемыеФайлы.Добавить(ПередаваемыйФайл);
		
		ПолучитьФайлы(ПолучаемыеФайлы, ПолученныеФайлы, ПараметрыВыполнения.БазовыйКаталогСохраненияФайла, Ложь);
	Исключение
		ИнформацияОбОшибке = ИнформацияОбОшибке();
	КонецПопытки;
	Если ИнформацияОбОшибке <> Неопределено Тогда
		ОбойтиДеревоФайлов15(ИнформацияОбОшибке, ПараметрыВыполнения);
		Возврат;
	КонецЕсли;
		
	Если ПолученныеФайлы.Количество() = 0 
		Или ПустаяСтрока(ПолученныеФайлы[0].Имя) Тогда
		// Файл не был получен.
		Возврат;
	КонецЕсли;
	
	// Для варианта с хранением файлов на диске (на сервере) удаляем файл из временного хранилища после получения.
	Если ЭтоАдресВременногоХранилища(АдресФайлаДляОткрытия) Тогда
		УдалитьИзВременногоХранилища(АдресФайлаДляОткрытия);
	КонецЕсли;
	
	ПараметрыВыполнения.ФайлНаДиске = Новый Файл(ПараметрыВыполнения.ПолноеИмяФайла);
	
	Попытка
		// Сделаем файл только для чтения.
		ПараметрыВыполнения.ФайлНаДиске.УстановитьТолькоЧтение(Истина);
		// Поставим время модификации - как в информационной базе.
		ПараметрыВыполнения.ФайлНаДиске.УстановитьУниверсальноеВремяИзменения(
			ПараметрыВыполнения.ЗаписьФайла.ДатаМодификацииУниверсальная);
	Исключение
		ИнформацияОбОшибке = ИнформацияОбОшибке();
	КонецПопытки;
	
	Если ИнформацияОбОшибке <> Неопределено Тогда
		ОбойтиДеревоФайлов15(ИнформацияОбОшибке, ПараметрыВыполнения);
		Возврат;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ОбойтиДеревоФайлов15(ИнформацияОбОшибке, ПараметрыВыполнения)
	// Ошибка при записи файла и изменении его атрибутов.
	ТекстВопроса = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
		НСтр("ru = 'Ошибка записи файла
		           |""%1"".
		           |
		           |%2.'"),
		ПараметрыВыполнения.ПолноеИмяФайла,
		КраткоеПредставлениеОшибки(ИнформацияОбОшибке));
	
	РаботаСФайламиСлужебныйКлиент.УстановитьПризнакБлокирующейФормы(ПараметрыВыполнения, Истина);
	Обработчик = Новый ОписаниеОповещения("ОбойтиДеревоФайлов16", ЭтотОбъект, ПараметрыВыполнения);
	
	ПоказатьВопрос(Обработчик, ТекстВопроса, РежимДиалогаВопрос.ПрерватьПовторитьПропустить, , КодВозвратаДиалога.Повторить);
КонецПроцедуры

&НаКлиенте
Процедура ОбойтиДеревоФайлов16(Ответ, ПараметрыВыполнения) Экспорт
	Если Ответ = КодВозвратаДиалога.Прервать Тогда
		// Просто выйдем с ошибкой
		ПараметрыВыполнения.Успех = Ложь;
		ПараметрыВыполнения.ТребуетсяЗапускЦикла = Ложь; // Цикл перезапускать не требуется.
		// Ложь.
		РаботаСФайламиСлужебныйКлиент.ВернутьРезультат(ПараметрыВыполнения.ОбработчикРезультата, ПараметрыВыполнения);
		Возврат;
	ИначеЕсли Ответ = КодВозвратаДиалога.Пропустить Тогда
		// Пропустим этот файл и пойдем дальше.
		Возврат;
	КонецЕсли;
	
	// Попробуем повторить создание папки.
	ОбойтиДеревоФайлов14(ПараметрыВыполнения);
КонецПроцедуры

&НаСервере
Процедура ИзменитьИменаФайловИПапок(ЭлементДерева)
	
	Для Каждого ФайлИлиПапка Из ЭлементДерева.Строки Цикл
		ФайлИлиПапка.НаименованиеПапки = СтроковыеФункции.СтрокаЛатиницей(ФайлИлиПапка.НаименованиеПапки);
		ФайлИлиПапка.ПолноеНаименование = СтроковыеФункции.СтрокаЛатиницей(ФайлИлиПапка.ПолноеНаименование);
		ФайлИлиПапка.Расширение = СтроковыеФункции.СтрокаЛатиницей(ФайлИлиПапка.Расширение);
		ИзменитьИменаФайловИПапок(ФайлИлиПапка);
	КонецЦикла;
	
КонецПроцедуры;

#КонецОбласти
