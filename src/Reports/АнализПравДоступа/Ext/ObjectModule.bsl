﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2020, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ПрограммныйИнтерфейс

#Область ДляВызоваИзДругихПодсистем

// Задать настройки формы отчета.
//
// Параметры:
//   Форма - ФормаКлиентскогоПриложения
//         - Неопределено
//   КлючВарианта - Строка
//                - Неопределено
//   Настройки - см. ОтчетыКлиентСервер.НастройкиОтчетаПоУмолчанию
//
Процедура ОпределитьНастройкиФормы(Форма, КлючВарианта, Настройки) Экспорт
	
	Настройки.ФормироватьСразу = Истина;
	Настройки.События.ПередЗагрузкойНастроекВКомпоновщик = Истина;
	Настройки.События.ПриСозданииНаСервере = Истина;
	Настройки.События.ПриОпределенииИспользуемыхТаблиц = Истина;
	
КонецПроцедуры

// См. ОтчетыПереопределяемый.ПриСозданииНаСервере
Процедура ПриСозданииНаСервере(Форма, Отказ, СтандартнаяОбработка) Экспорт
	
	Если ЗначениеЗаполнено(Форма.НастройкиОтчета.ВариантСсылка) Тогда
		Форма.НастройкиОтчета.Наименование = Форма.НастройкиОтчета.ВариантСсылка;
	КонецЕсли;
	
	Если Форма.КонтекстВарианта = Метаданные.Справочники.Пользователи.ПолноеИмя() Тогда 
		Если Форма.Параметры.ПараметрКоманды.Количество() > 1 Тогда
			Форма.КлючТекущегоВарианта = "ПраваПользователейНаТаблицы";
			Форма.Параметры.КлючВарианта = "ПраваПользователейНаТаблицы";
		Иначе
			Форма.КлючТекущегоВарианта = "ПраваПользователяНаТаблицы";
			Форма.Параметры.КлючВарианта = "ПраваПользователяНаТаблицы";
		КонецЕсли;
		Форма.ВариантыКонтекста.Очистить();
		Форма.ВариантыКонтекста.Добавить(Форма.КлючТекущегоВарианта);
	КонецЕсли;
	
	Если УправлениеДоступомСлужебный.УпрощенныйИнтерфейсНастройкиПравДоступа() Тогда
		Форма.НастройкиОтчета.СхемаМодифицирована = Истина;
		Схема = ПолучитьИзВременногоХранилища(Форма.НастройкиОтчета.АдресСхемы);
		Поле = Схема.НаборыДанных.ПраваПользователей.Поля.Найти("ГруппаДоступа");
		Поле.Заголовок = НСтр("ru = 'Профиль пользователя'");
		Поле.ТипЗначения = Новый ОписаниеТипов("СправочникСсылка.ПрофилиГруппДоступа");
		Форма.НастройкиОтчета.АдресСхемы = ПоместитьВоВременноеХранилище(Схема, Форма.УникальныйИдентификатор);
	КонецЕсли;
	
КонецПроцедуры

// Вызывается перед загрузкой новых настроек. Используется для изменения схемы компоновки.
//   Например, если схема отчета зависит от ключа варианта или параметров отчета.
//   Чтобы изменения схемы вступили в силу следует вызывать метод ОтчетыСервер.ПодключитьСхему().
//
// Параметры:
//   Контекст - Произвольный - 
//       Параметры контекста, в котором используется отчет.
//       Используется для передачи в параметрах метода ОтчетыСервер.ПодключитьСхему().
//   КлючСхемы - Строка -
//       Идентификатор текущей схемы компоновщика настроек.
//       По умолчанию не заполнен (это означает что компоновщик инициализирован на основании основной схемы).
//       Используется для оптимизации, чтобы переинициализировать компоновщик как можно реже).
//       Может не использоваться если переинициализация выполняется безусловно.
//   КлючВарианта - Строка
//                - Неопределено -
//       Имя предопределенного или уникальный идентификатор пользовательского варианта отчета.
//       Неопределено когда вызов для варианта расшифровки или без контекста.
//   НовыеНастройкиКД - НастройкиКомпоновкиДанных
//                    - Неопределено -
//       Настройки варианта отчета, которые будут загружены в компоновщик настроек после его инициализации.
//       Неопределено когда настройки варианта не надо загружать (уже загружены ранее).
//   НовыеПользовательскиеНастройкиКД - ПользовательскиеНастройкиКомпоновкиДанных
//                                    - Неопределено -
//       Пользовательские настройки, которые будут загружены в компоновщик настроек после его инициализации.
//       Неопределено когда пользовательские настройки не надо загружать (уже загружены ранее).
//
// Пример:
//  // Компоновщик отчета инициализируется на основании схемы из общих макетов:
//	Если КлючСхемы <> "1" Тогда
//		КлючСхемы = "1";
//		СхемаКД = ПолучитьОбщийМакет("МояОбщаяСхемаКомпоновки");
//		ОтчетыСервер.ПодключитьСхему(ЭтотОбъект, Контекст, СхемаКД, КлючСхемы);
//	КонецЕсли;
//
//  // Схема зависит от значения параметра, выведенного в пользовательские настройки отчета:
//	Если ТипЗнч(НовыеПользовательскиеНастройкиКД) = Тип("ПользовательскиеНастройкиКомпоновкиДанных") Тогда
//		ПолноеИмяОбъектаМетаданных = "";
//		Для Каждого ЭлементКД Из НовыеПользовательскиеНастройкиКД.Элементы Цикл
//			Если ТипЗнч(ЭлементКД) = Тип("ЗначениеПараметраНастроекКомпоновкиДанных") Тогда
//				ИмяПараметра = Строка(ЭлементКД.Параметр);
//				Если ИмяПараметра = "ОбъектМетаданных" Тогда
//					ПолноеИмяОбъектаМетаданных = ЭлементКД.Значение;
//				КонецЕсли;
//			КонецЕсли;
//		КонецЦикла;
//		Если КлючСхемы <> ПолноеИмяОбъектаМетаданных Тогда
//			КлючСхемы = ПолноеИмяОбъектаМетаданных;
//			СхемаКД = Новый СхемаКомпоновкиДанных;
//			// Наполнение схемы...
//			ОтчетыСервер.ПодключитьСхему(ЭтотОбъект, Контекст, СхемаКД, КлючСхемы);
//		КонецЕсли;
//	КонецЕсли;
//
Процедура ПередЗагрузкойНастроекВКомпоновщик(Контекст, КлючСхемы, КлючВарианта, НовыеНастройкиКД, НовыеПользовательскиеНастройкиКД) Экспорт
	
	Если НовыеНастройкиКД <> Неопределено Тогда
		УникальныйИдентификатор = Неопределено;
		Если ТипЗнч(Контекст) = Тип("ФормаКлиентскогоПриложения") Тогда
			УникальныйИдентификатор = Контекст.УникальныйИдентификатор;
		КонецЕсли;
		
		НовыеНастройкиКД.ДополнительныеСвойства.Вставить("АдресКартинкиПросмотр", ПоместитьВоВременноеХранилище(Неопределено, УникальныйИдентификатор));
		НовыеНастройкиКД.ДополнительныеСвойства.Вставить("АдресКартинкиРедактирование", ПоместитьВоВременноеХранилище(Неопределено, УникальныйИдентификатор));
		НовыеНастройкиКД.ДополнительныеСвойства.Вставить("АдресКартинкиСоздание", ПоместитьВоВременноеХранилище(Неопределено, УникальныйИдентификатор));
	КонецЕсли;
	
	Если КлючСхемы = "1" Тогда
		Возврат;
	КонецЕсли;
	
	КлючСхемы = "1";
	
	Если ТипЗнч(Контекст) = Тип("ФормаКлиентскогоПриложения") И НовыеНастройкиКД <> Неопределено Тогда
		
		РеквизитыФормы = Новый Структура("КонтекстВарианта");
		ЗаполнитьЗначенияСвойств(РеквизитыФормы, Контекст);
		
		Если ЗначениеЗаполнено(РеквизитыФормы.КонтекстВарианта) Тогда
			Если КлючВарианта = "ПраваПользователейНаТаблицу" Тогда
				ОбъектМетаданных = ОбщегоНазначения.ИдентификаторОбъектаМетаданных(Контекст.КонтекстВарианта, Ложь);
				Если ЗначениеЗаполнено(ОбъектМетаданных) Тогда
					ОбщегоНазначенияКлиентСервер.УстановитьЭлементОтбора(НовыеНастройкиКД.Отбор, "ОбъектМетаданных", ОбъектМетаданных,
						ВидСравненияКомпоновкиДанных.Равно, , Истина);
				КонецЕсли;
			ИначеЕсли КлючВарианта = "ПраваПользователейНаТаблицы" Или КлючВарианта = "ПраваПользователяНаТаблицы" Тогда
				Если Контекст.Параметры.Свойство("ПараметрКоманды") Тогда
					СписокПользователей = Новый СписокЗначений;
					СписокПользователей.ЗагрузитьЗначения(Контекст.Параметры.ПараметрКоманды);
					УстановитьОтборПоПользователям(НовыеНастройкиКД, СписокПользователей);
				КонецЕсли;
			КонецЕсли;
		КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры

// Список регистров и других объектов метаданных, по которым формируется отчет.
//   Используется для проверки что отчет может содержать не обновленные данные.
//
// Параметры:
//   КлючВарианта - Строка
//                - Неопределено -
//       Имя предопределенного или уникальный идентификатор пользовательского варианта отчета.
//       Неопределено когда вызов для варианта расшифровки или без контекста.
//   ИспользуемыеТаблицы - Массив - 
//       Полные имена объектов метаданных (регистров, документов и других таблиц),
//       данные которых выводятся в отчете.
//
// Пример:
//	ИспользуемыеТаблицы.Добавить(Метаданные.Документы._ДемоЗаказПокупателя.ПолноеИмя());
//
Процедура ПриОпределенииИспользуемыхТаблиц(КлючВарианта, ИспользуемыеТаблицы) Экспорт
	
	ИспользуемыеТаблицы.Добавить(Метаданные.РегистрыСведений.ПраваРолей.ПолноеИмя());
	
КонецПроцедуры

#КонецОбласти

#КонецОбласти

#Область ОбработчикиСобытий

Процедура ПриКомпоновкеРезультата(ДокументРезультат, ДанныеРасшифровки, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
	НастройкиКомпоновщика = КомпоновщикНастроек.ПолучитьНастройки();
	
	КомпоновщикМакета = Новый КомпоновщикМакетаКомпоновкиДанных;
	МакетКомпоновки = КомпоновщикМакета.Выполнить(СхемаКомпоновкиДанных, НастройкиКомпоновщика, ДанныеРасшифровки);
	
	ВнешниеНаборыДанных = Новый Структура;
	ВнешниеНаборыДанных.Вставить("ПраваПользователей", ПраваПользователей());
	
	ПроцессорКомпоновки = Новый ПроцессорКомпоновкиДанных;
	ПроцессорКомпоновки.Инициализировать(МакетКомпоновки, ВнешниеНаборыДанных , ДанныеРасшифровки);
	
	ПроцессорВывода = Новый ПроцессорВыводаРезультатаКомпоновкиДанныхВТабличныйДокумент;
	ПроцессорВывода.УстановитьДокумент(ДокументРезультат);
	
	ПроцессорВывода.Вывести(ПроцессорКомпоновки);
	
	ГруппаДоступаЗаголовок = НСтр("ru = 'Группа доступа'");
	Если УправлениеДоступомСлужебный.УпрощенныйИнтерфейсНастройкиПравДоступа() Тогда
		ГруппаДоступаЗаголовок = НСтр("ru = 'Профиль пользователя'");
	КонецЕсли;
	
	Для НомерСтроки = 1 По ДокументРезультат.ВысотаТаблицы Цикл
		Для НомерКолонки = 1 По ДокументРезультат.ШиринаТаблицы Цикл
			Область = ДокументРезультат.Область(НомерСтроки, НомерКолонки);
			Если Область.Текст = "&ГруппаДоступаЗаголовок" Тогда
				Область.Текст = ГруппаДоступаЗаголовок;
			КонецЕсли;
			
			Если ТипЗнч(Область.Расшифровка) <> Тип("ИдентификаторРасшифровкиКомпоновкиДанных") Тогда
				Продолжить;
			КонецЕсли;
			
			ЗначенияПолей = ДанныеРасшифровки.Элементы[Область.Расшифровка].ПолучитьПоля();
			
			Если ЗначенияПолей.Найти("Право") <> Неопределено Тогда
				Если Область.Текст = "1" Тогда
					Область.Картинка = БиблиотекаКартинок.Просмотр;
					Область.Текст = "";
				ИначеЕсли Область.Текст = "2" Тогда
					Область.Картинка = БиблиотекаКартинок.Редактирование;
					Область.Текст = "";
				ИначеЕсли Область.Текст = "3" Тогда
					Область.Картинка = БиблиотекаКартинок.Создание;
					Область.Текст = "";
				КонецЕсли;
			КонецЕсли;
		КонецЦикла;
	КонецЦикла;
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Функция ТаблицыОтчетов()
	
	Результат = ПустаяКоллекцияТаблицОтчетов();
	
	Отчет = ВыбранныйОтчет();
	ИспользуемыеТаблицы = Неопределено;
	Если ЗначениеЗаполнено(Отчет)
		И КомпоновщикНастроек.ПользовательскиеНастройки.ДополнительныеСвойства.Свойство("ИспользуемыеТаблицы", ИспользуемыеТаблицы)
		И ИспользуемыеТаблицы <> Неопределено Тогда 
		ИдентификаторыОбъектовМетаданных = ОбщегоНазначения.ИдентификаторыОбъектовМетаданных(ИспользуемыеТаблицы, Ложь);
		Для Каждого Таблица Из ИспользуемыеТаблицы Цикл
			ОбъектМетаданных = ИдентификаторыОбъектовМетаданных[Таблица];
			СтрокаТаблицы = Результат.Добавить();
			СтрокаТаблицы.Отчет = Отчет;
			СтрокаТаблицы.ОбъектМетаданных = ОбъектМетаданных;
		КонецЦикла;
		
		Возврат Результат;
	КонецЕсли;
	
	Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.ВариантыОтчетов") Тогда
		МодульВариантыОтчетов = ОбщегоНазначения.ОбщийМодуль("ВариантыОтчетов");
	Иначе
		Возврат Результат;
	КонецЕсли;
	
	ТаблицыОтчетов = Новый ТаблицаЗначений;
	ТаблицыОтчетов.Колонки.Добавить("Отчет");
	ТаблицыОтчетов.Колонки.Добавить("ОбъектМетаданных");
	
	ВладельцыТаблиц = Новый Соответствие;
	
	Для Каждого ОбъектМетаданных Из Метаданные.Отчеты Цикл
		Если Не ПравоДоступа("Просмотр", ОбъектМетаданных) Тогда
			Продолжить;
		КонецЕсли;
		ИспользуемыеТаблицы = МодульВариантыОтчетов.ИспользуемыеТаблицыОтчета(ОбъектМетаданных);
		
		Для Каждого ИмяТаблицы Из ИспользуемыеТаблицы Цикл
			ИспользуемаяТаблица = ВладельцыТаблиц[ИмяТаблицы];
			Если ИспользуемаяТаблица = Неопределено Тогда
				ВладелецТаблицы = ИмяТаблицы;
				ЧастиСтроки = СтрРазделить(ВладелецТаблицы, ".", Истина);
				Если ЧастиСтроки.Количество() = 1 Тогда
					Продолжить;
				КонецЕсли;
				Если ЧастиСтроки.Количество() > 2 Тогда
					ВладелецТаблицы = ЧастиСтроки[0] + "." + ЧастиСтроки[1];
				КонецЕсли;
				ВладельцыТаблиц.Вставить(ИмяТаблицы, ВладелецТаблицы);
				ИспользуемаяТаблица = ВладелецТаблицы;
			КонецЕсли;
			
			СтрокаТаблицы = ТаблицыОтчетов.Добавить();
			СтрокаТаблицы.Отчет = ОбъектМетаданных.ПолноеИмя();
			СтрокаТаблицы.ОбъектМетаданных = ИспользуемаяТаблица;
		КонецЦикла;
	КонецЦикла;
	
	ТаблицыОтчетов.Свернуть("Отчет, ОбъектМетаданных");
	
	ИменаОбъектовМетаданных = ТаблицыОтчетов.ВыгрузитьКолонку("ОбъектМетаданных");
	Для Каждого ОбъектМетаданных Из Метаданные.Отчеты Цикл
		ИменаОбъектовМетаданных.Добавить(ОбъектМетаданных.ПолноеИмя());
	КонецЦикла;
	
	ИдентификаторыОбъектовМетаданных = ОбщегоНазначения.ИдентификаторыОбъектовМетаданных(ИменаОбъектовМетаданных, Ложь);
	
	Для Каждого СтрокаТаблицы Из ТаблицыОтчетов Цикл
		ИмяТаблицы = СтрокаТаблицы.ОбъектМетаданных;
		ИспользуемаяТаблица = ИдентификаторыОбъектовМетаданных[ИмяТаблицы];
		СтрокаТаблицы.ОбъектМетаданных = ИспользуемаяТаблица;
		СтрокаТаблицы.Отчет = ИдентификаторыОбъектовМетаданных[СтрокаТаблицы.Отчет];
	КонецЦикла;
	
	Для Каждого СтрокаТаблицы Из ТаблицыОтчетов Цикл
		ЗаполнитьЗначенияСвойств(Результат.Добавить(), СтрокаТаблицы);
	КонецЦикла;
	
	Возврат Результат;
	
КонецФункции

Функция ПустаяКоллекцияТаблицОтчетов()
	
	Результат = Новый ТаблицаЗначений;
	Результат.Колонки.Добавить("Отчет", Новый ОписаниеТипов("СправочникСсылка.ИдентификаторыОбъектовМетаданных,СправочникСсылка.ИдентификаторыОбъектовРасширений"));
	Результат.Колонки.Добавить("ОбъектМетаданных", Новый ОписаниеТипов("СправочникСсылка.ИдентификаторыОбъектовМетаданных,СправочникСсылка.ИдентификаторыОбъектовРасширений"));
	
	Возврат Результат;
	
КонецФункции

Функция Отчеты()
	
	Результат = Новый СписокЗначений;
	
	ИменаОтчетов = Новый Массив;
	Для Каждого ОбъектМетаданных Из Метаданные.Отчеты Цикл
		ИменаОтчетов.Добавить(ОбъектМетаданных.ПолноеИмя());
	КонецЦикла;
	
	ИдентификаторыОбъектовМетаданных = ОбщегоНазначения.ИдентификаторыОбъектовМетаданных(ИменаОтчетов, Ложь);
	
	Для Каждого Отчет Из ИменаОтчетов Цикл
		Результат.Добавить(ИдентификаторыОбъектовМетаданных[Отчет]);
	КонецЦикла;
	
	Возврат Результат;
	
КонецФункции

Функция ПраваОтчетов()
	
	Результат = ПустаяКоллекцияПравОтчетов();
	
	ИменаОбъектовМетаданных = Новый Массив;
	Для Каждого ИмяКоллекции Из СтрРазделить("Отчеты,Роли", ",", Ложь) Цикл
		Для Каждого ОбъектМетаданных Из Метаданные[ИмяКоллекции] Цикл
			ИменаОбъектовМетаданных.Добавить(ОбъектМетаданных.ПолноеИмя());
		КонецЦикла;
	КонецЦикла;
	
	ИдентификаторыОбъектовМетаданных = ОбщегоНазначения.ИдентификаторыОбъектовМетаданных(ИменаОбъектовМетаданных, Ложь);
	
	Для Каждого Отчет Из Метаданные.Отчеты Цикл
		Для Каждого Роль Из Метаданные.Роли Цикл
			Если ПравоДоступа("Просмотр", Отчет, Роль) Тогда
				СтрокаТаблицы = Результат.Добавить();
				СтрокаТаблицы.Отчет= ИдентификаторыОбъектовМетаданных[Отчет.ПолноеИмя()];
				СтрокаТаблицы.Роль = ИдентификаторыОбъектовМетаданных[Роль.ПолноеИмя()];
				СтрокаТаблицы.Просмотр = Истина;
			КонецЕсли;
		КонецЦикла;
	КонецЦикла;
	
	Возврат Результат;
	
КонецФункции

Функция ПустаяКоллекцияПравОтчетов()
	
	Результат = Новый ТаблицаЗначений;
	Результат.Колонки.Добавить("Отчет", Новый ОписаниеТипов("СправочникСсылка.ИдентификаторыОбъектовМетаданных,СправочникСсылка.ИдентификаторыОбъектовРасширений"));
	Результат.Колонки.Добавить("Роль", Новый ОписаниеТипов("СправочникСсылка.ИдентификаторыОбъектовМетаданных,СправочникСсылка.ИдентификаторыОбъектовРасширений"));
	Результат.Колонки.Добавить("Просмотр", Новый ОписаниеТипов("Булево"));
	
	Возврат Результат;
	
КонецФункции

Функция ПраваПользователей()
	
	ТекстЗапроса = 
	"ВЫБРАТЬ
	|	Пользователи.Ссылка КАК Ссылка,
	|	НЕ Пользователи.Недействителен
	|		И НЕ Пользователи.ПометкаУдаления КАК ВходВПрограммуРазрешен
	|ПОМЕСТИТЬ ВсеПользователи
	|ИЗ
	|	Справочник.Пользователи КАК Пользователи
	|
	|ИНДЕКСИРОВАТЬ ПО
	|	Ссылка
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ГруппыДоступаПользователи.Пользователь КАК Пользователь,
	|	ГруппыДоступа.Профиль КАК Профиль,
	|	ГруппыДоступаПользователи.Ссылка КАК ГруппаДоступа
	|ПОМЕСТИТЬ ГруппыДоступаПользователей
	|ИЗ
	|	Справочник.ГруппыДоступа.Пользователи КАК ГруппыДоступаПользователи
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.ГруппыДоступа КАК ГруппыДоступа
	|		ПО ГруппыДоступаПользователи.Ссылка = ГруппыДоступа.Ссылка
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ ВсеПользователи КАК ВсеПользователи
	|		ПО ГруппыДоступаПользователи.Пользователь = ВсеПользователи.Ссылка
	|ГДЕ
	|	НЕ ГруппыДоступа.ПометкаУдаления
	|
	|СГРУППИРОВАТЬ ПО
	|	ГруппыДоступаПользователи.Пользователь,
	|	ГруппыДоступа.Профиль,
	|	ГруппыДоступаПользователи.Ссылка
	|
	|ИНДЕКСИРОВАТЬ ПО
	|	Профиль
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ПраваРолей.Отчет КАК Отчет,
	|	ПраваРолей.Роль КАК Роль,
	|	ПраваРолей.Просмотр КАК Просмотр
	|ПОМЕСТИТЬ ПраваРолейНаОтчеты
	|ИЗ
	|	&ПраваОтчетов КАК ПраваРолей
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ПраваРолейРасширений.ОбъектМетаданных КАК ОбъектМетаданных,
	|	ПраваРолейРасширений.Роль КАК Роль,
	|	ПраваРолейРасширений.Просмотр КАК Просмотр,
	|	ПраваРолейРасширений.Редактирование КАК Редактирование,
	|	ПраваРолейРасширений.ИнтерактивноеДобавление КАК ИнтерактивноеДобавление,
	|	ПраваРолейРасширений.ВидИзмененияСтроки КАК ВидИзмененияСтроки
	|ПОМЕСТИТЬ ПраваРолейРасширений
	|ИЗ
	|	&ПраваРолейРасширений КАК ПраваРолейРасширений
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ПраваРолейРасширений.ОбъектМетаданных КАК ОбъектМетаданных,
	|	ПраваРолейРасширений.Роль КАК Роль,
	|	ПраваРолейРасширений.Просмотр КАК Просмотр,
	|	ПраваРолейРасширений.Редактирование КАК Редактирование,
	|	ПраваРолейРасширений.ИнтерактивноеДобавление КАК ИнтерактивноеДобавление
	|ПОМЕСТИТЬ ПраваРолей
	|ИЗ
	|	ПраваРолейРасширений КАК ПраваРолейРасширений
	|ГДЕ
	|	ПраваРолейРасширений.ВидИзмененияСтроки = 1
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	ПраваРолей.ОбъектМетаданных,
	|	ПраваРолей.Роль,
	|	ПраваРолей.Просмотр,
	|	ПраваРолей.Редактирование,
	|	ПраваРолей.ИнтерактивноеДобавление
	|ИЗ
	|	РегистрСведений.ПраваРолей КАК ПраваРолей
	|		ЛЕВОЕ СОЕДИНЕНИЕ ПраваРолейРасширений КАК ПраваРолейРасширений
	|		ПО ПраваРолей.ОбъектМетаданных = ПраваРолейРасширений.ОбъектМетаданных
	|			И ПраваРолей.Роль = ПраваРолейРасширений.Роль
	|ГДЕ
	|	ПраваРолейРасширений.ОбъектМетаданных ЕСТЬ NULL
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	ПраваРолей.Отчет,
	|	ПраваРолей.Роль,
	|	ПраваРолей.Просмотр,
	|	ЛОЖЬ,
	|	ЛОЖЬ
	|ИЗ
	|	ПраваРолейНаОтчеты КАК ПраваРолей
	|
	|ИНДЕКСИРОВАТЬ ПО
	|	ПраваРолейРасширений.Роль
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ПраваРолей.ОбъектМетаданных КАК ОбъектМетаданных,
	|	ПраваРолей.Роль КАК Роль,
	|	ПраваРолей.Просмотр КАК Просмотр,
	|	ПраваРолей.Редактирование КАК Редактирование,
	|	ПраваРолей.ИнтерактивноеДобавление КАК ИнтерактивноеДобавление,
	|	ПрофилиГруппДоступаРоли.Ссылка КАК Профиль
	|ПОМЕСТИТЬ ПраваПрофилей
	|ИЗ
	|	ПраваРолей КАК ПраваРолей
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.ПрофилиГруппДоступа.Роли КАК ПрофилиГруппДоступаРоли
	|		ПО ПраваРолей.Роль = ПрофилиГруппДоступаРоли.Роль
	|
	|СГРУППИРОВАТЬ ПО
	|	ПраваРолей.ОбъектМетаданных,
	|	ПраваРолей.Роль,
	|	ПрофилиГруппДоступаРоли.Ссылка,
	|	ПраваРолей.ИнтерактивноеДобавление,
	|	ПраваРолей.Просмотр,
	|	ПраваРолей.Редактирование
	|
	|ИНДЕКСИРОВАТЬ ПО
	|	Профиль
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ТаблицыОтчетов.Отчет КАК Отчет,
	|	ТаблицыОтчетов.ОбъектМетаданных КАК Таблица
	|ПОМЕСТИТЬ ТаблицыОтчетов
	|ИЗ
	|	&ТаблицыОтчетов КАК ТаблицыОтчетов
	|
	|ИНДЕКСИРОВАТЬ ПО
	|	Таблица
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ГруппыДоступаПользователей.Пользователь КАК Пользователь,
	|	ГруппыДоступаПользователей.ГруппаДоступа КАК ГруппаДоступа,
	|	ПраваПрофилей.ОбъектМетаданных КАК ОбъектМетаданных,
	|	МАКСИМУМ(ПраваПрофилей.Просмотр) КАК Просмотр,
	|	МАКСИМУМ(ПраваПрофилей.Редактирование) КАК Редактирование,
	|	МАКСИМУМ(ПраваПрофилей.ИнтерактивноеДобавление) КАК ИнтерактивноеДобавление,
	|	ПраваПрофилей.Профиль КАК Профиль
	|ПОМЕСТИТЬ ПраваОбъектов
	|ИЗ
	|	ГруппыДоступаПользователей КАК ГруппыДоступаПользователей
	|		ЛЕВОЕ СОЕДИНЕНИЕ ПраваПрофилей КАК ПраваПрофилей
	|		ПО ГруппыДоступаПользователей.Профиль = ПраваПрофилей.Профиль
	|
	|СГРУППИРОВАТЬ ПО
	|	ГруппыДоступаПользователей.Пользователь,
	|	ГруппыДоступаПользователей.ГруппаДоступа,
	|	ПраваПрофилей.ОбъектМетаданных,
	|	ПраваПрофилей.Профиль
	|
	|ИНДЕКСИРОВАТЬ ПО
	|	ОбъектМетаданных
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ПраваОбъектов.Пользователь КАК Пользователь,
	|	ПраваОбъектов.ГруппаДоступа КАК ГруппаДоступа,
	|	ПраваОбъектов.ОбъектМетаданных КАК ОбъектМетаданных,
	|	ПраваОбъектов.Просмотр КАК Просмотр
	|ПОМЕСТИТЬ ПраваОтчетов
	|ИЗ
	|	ПраваОбъектов КАК ПраваОбъектов
	|ГДЕ
	|	ПраваОбъектов.ОбъектМетаданных В(&Отчеты)
	|
	|ИНДЕКСИРОВАТЬ ПО
	|	ОбъектМетаданных,
	|	Пользователь,
	|	ГруппаДоступа
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ПраваОбъектов.Пользователь КАК Пользователь,
	|	ПраваОбъектов.ГруппаДоступа КАК ГруппаДоступа,
	|	ПраваОбъектов.ОбъектМетаданных КАК ОбъектМетаданных,
	|	ПраваОбъектов.Просмотр КАК Просмотр,
	|	ПраваОбъектов.Редактирование КАК Редактирование,
	|	ПраваОбъектов.ИнтерактивноеДобавление КАК ИнтерактивноеДобавление,
	|	ТаблицыОтчетов.Отчет КАК Отчет,
	|	ПраваОбъектов.Профиль КАК Профиль
	|ПОМЕСТИТЬ ПраваОбъектовИСвязанныеОтчеты
	|ИЗ
	|	ПраваОбъектов КАК ПраваОбъектов
	|		ЛЕВОЕ СОЕДИНЕНИЕ ТаблицыОтчетов КАК ТаблицыОтчетов
	|		ПО ПраваОбъектов.ОбъектМетаданных = ТаблицыОтчетов.Таблица
	|ГДЕ
	|	НЕ ПраваОбъектов.ОбъектМетаданных В (&Отчеты)
	|
	|ИНДЕКСИРОВАТЬ ПО
	|	Пользователь,
	|	ОбъектМетаданных,
	|	ГруппаДоступа
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ПраваОбъектовИСвязанныеОтчеты.Пользователь КАК Пользователь,
	|	ПраваОбъектовИСвязанныеОтчеты.ГруппаДоступа КАК ГруппаДоступа,
	|	ПраваОбъектовИСвязанныеОтчеты.ОбъектМетаданных КАК ОбъектМетаданных,
	|	ПраваОбъектовИСвязанныеОтчеты.Просмотр КАК Просмотр,
	|	ПраваОбъектовИСвязанныеОтчеты.Редактирование КАК Редактирование,
	|	ПраваОбъектовИСвязанныеОтчеты.ИнтерактивноеДобавление КАК ИнтерактивноеДобавление,
	|	ВЫБОР
	|		КОГДА ПраваОбъектовИСвязанныеОтчеты.ИнтерактивноеДобавление
	|			ТОГДА 3
	|		КОГДА ПраваОбъектовИСвязанныеОтчеты.Редактирование
	|			ТОГДА 2
	|		КОГДА ПраваОбъектовИСвязанныеОтчеты.Просмотр
	|			ТОГДА 1
	|		ИНАЧЕ 0
	|	КОНЕЦ КАК Право,
	|	ВЫБОР
	|		КОГДА ПраваОбъектовИСвязанныеОтчеты.ИнтерактивноеДобавление
	|			ТОГДА &КартинкаСоздание
	|		КОГДА ПраваОбъектовИСвязанныеОтчеты.Редактирование
	|			ТОГДА &КартинкаРедактирование
	|		КОГДА ПраваОбъектовИСвязанныеОтчеты.Просмотр
	|			ТОГДА &КартинкаПросмотр
	|		ИНАЧЕ 0
	|	КОНЕЦ КАК КартинкаПраво,
	|	ВЫБОР
	|		КОГДА ПраваОбъектовИСвязанныеОтчеты.Просмотр
	|			ТОГДА &КартинкаПросмотр
	|		ИНАЧЕ """"
	|	КОНЕЦ КАК КартинкаПросмотр,
	|	ВЫБОР
	|		КОГДА ПраваОбъектовИСвязанныеОтчеты.Редактирование
	|			ТОГДА &КартинкаРедактирование
	|		ИНАЧЕ """"
	|	КОНЕЦ КАК КартинкаРедактирование,
	|	ВЫБОР
	|		КОГДА ПраваОбъектовИСвязанныеОтчеты.ИнтерактивноеДобавление
	|			ТОГДА &КартинкаСоздание
	|		ИНАЧЕ """"
	|	КОНЕЦ КАК КартинкаСоздание,
	|	ПраваОбъектовИСвязанныеОтчеты.Отчет КАК Отчет,
	|	ПраваОтчетов.ГруппаДоступа КАК ГруппаДоступаОтчета,
	|	ВЫБОР
	|		КОГДА ПраваОтчетов.Просмотр
	|			ТОГДА 1
	|		ИНАЧЕ 0
	|	КОНЕЦ КАК ПравоОтчета,
	|	ПраваОбъектовИСвязанныеОтчеты.Профиль КАК Профиль
	|ПОМЕСТИТЬ ПраваПользователейСНастроеннымиПравами
	|ИЗ
	|	ПраваОбъектовИСвязанныеОтчеты КАК ПраваОбъектовИСвязанныеОтчеты
	|		ЛЕВОЕ СОЕДИНЕНИЕ ПраваОтчетов КАК ПраваОтчетов
	|		ПО ПраваОбъектовИСвязанныеОтчеты.Пользователь = ПраваОтчетов.Пользователь
	|			И ПраваОбъектовИСвязанныеОтчеты.Отчет = ПраваОтчетов.ОбъектМетаданных
	|			И ПраваОбъектовИСвязанныеОтчеты.ГруппаДоступа = ПраваОтчетов.ГруппаДоступа
	|ГДЕ
	|	НЕ ПраваОбъектовИСвязанныеОтчеты.ОбъектМетаданных ЕСТЬ NULL
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ПраваОбъектовИСвязанныеОтчеты.ОбъектМетаданных КАК ОбъектМетаданных,
	|	ПраваОбъектовИСвязанныеОтчеты.Отчет КАК Отчет
	|ПОМЕСТИТЬ ВсеОбъектыСПравами
	|ИЗ
	|	ПраваОбъектовИСвязанныеОтчеты КАК ПраваОбъектовИСвязанныеОтчеты
	|
	|СГРУППИРОВАТЬ ПО
	|	ПраваОбъектовИСвязанныеОтчеты.ОбъектМетаданных,
	|	ПраваОбъектовИСвязанныеОтчеты.Отчет
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ВсеПользователи.Ссылка КАК Пользователь,
	|	ВсеОбъектыСПравами.ОбъектМетаданных КАК ОбъектМетаданных,
	|	ВсеОбъектыСПравами.Отчет КАК Отчет,
	|	ВсеПользователи.ВходВПрограммуРазрешен КАК ВходВПрограммуРазрешен
	|ПОМЕСТИТЬ ВсеПользователиИОбъекты
	|ИЗ
	|	ВсеПользователи КАК ВсеПользователи,
	|	ВсеОбъектыСПравами КАК ВсеОбъектыСПравами
	|
	|СГРУППИРОВАТЬ ПО
	|	ВсеПользователи.Ссылка,
	|	ВсеОбъектыСПравами.ОбъектМетаданных,
	|	ВсеОбъектыСПравами.Отчет,
	|	ВсеПользователи.ВходВПрограммуРазрешен
	|
	|ИНДЕКСИРОВАТЬ ПО
	|	Пользователь,
	|	ОбъектМетаданных,
	|	Отчет
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ЕСТЬNULL(ПраваПользователейСНастроеннымиПравами.Пользователь, ВсеПользователиИОбъекты.Пользователь) КАК Пользователь,
	|	ВЫБОР
	|		КОГДА &УпрощенныйИнтерфейсНастройкиПравДоступа
	|			ТОГДА ПраваПользователейСНастроеннымиПравами.Профиль
	|		ИНАЧЕ ПраваПользователейСНастроеннымиПравами.ГруппаДоступа
	|	КОНЕЦ КАК ГруппаДоступа,
	|	ЕСТЬNULL(ПраваПользователейСНастроеннымиПравами.ОбъектМетаданных, ВсеПользователиИОбъекты.ОбъектМетаданных) КАК ОбъектМетаданных,
	|	ЕСТЬNULL(ПраваПользователейСНастроеннымиПравами.Просмотр, ЛОЖЬ) КАК Просмотр,
	|	ЕСТЬNULL(ПраваПользователейСНастроеннымиПравами.Редактирование, ЛОЖЬ) КАК Редактирование,
	|	ЕСТЬNULL(ПраваПользователейСНастроеннымиПравами.ИнтерактивноеДобавление, ЛОЖЬ) КАК ИнтерактивноеДобавление,
	|	ЕСТЬNULL(ПраваПользователейСНастроеннымиПравами.Право, 0) КАК Право,
	|	ПраваПользователейСНастроеннымиПравами.КартинкаПраво КАК КартинкаПраво,
	|	ПраваПользователейСНастроеннымиПравами.КартинкаПросмотр КАК КартинкаПросмотр,
	|	ПраваПользователейСНастроеннымиПравами.КартинкаРедактирование КАК КартинкаРедактирование,
	|	ПраваПользователейСНастроеннымиПравами.КартинкаСоздание КАК КартинкаСоздание,
	|	ЕСТЬNULL(ПраваПользователейСНастроеннымиПравами.Отчет, ВсеПользователиИОбъекты.Отчет) КАК Отчет,
	|	ПраваПользователейСНастроеннымиПравами.ГруппаДоступаОтчета КАК ГруппаДоступаОтчета,
	|	ПраваПользователейСНастроеннымиПравами.ПравоОтчета КАК ПравоОтчета,
	|	ВсеПользователиИОбъекты.ВходВПрограммуРазрешен КАК ВходВПрограммуРазрешен
	|ИЗ
	|	ВсеПользователиИОбъекты КАК ВсеПользователиИОбъекты
	|		ПОЛНОЕ СОЕДИНЕНИЕ ПраваПользователейСНастроеннымиПравами КАК ПраваПользователейСНастроеннымиПравами
	|		ПО (ПраваПользователейСНастроеннымиПравами.Пользователь = ВсеПользователиИОбъекты.Пользователь)
	|			И (ПраваПользователейСНастроеннымиПравами.ОбъектМетаданных = ВсеПользователиИОбъекты.ОбъектМетаданных)
	|ГДЕ
	|	(НЕ &ЕстьОтборПоПользователям
	|			ИЛИ ЕСТЬNULL(ПраваПользователейСНастроеннымиПравами.Пользователь, ВсеПользователиИОбъекты.Пользователь) В (&Пользователь))";
	
	ВключенаГруппировкаПоОтчетам = ВключенаГруппировкаПоОтчетам();
	
	Запрос = Новый Запрос(ТекстЗапроса);
	Запрос.УстановитьПараметр("ПраваОтчетов", ?(ВключенаГруппировкаПоОтчетам, ПраваОтчетов(), ПустаяКоллекцияПравОтчетов()));
	Запрос.УстановитьПараметр("ТаблицыОтчетов", ?(ВключенаГруппировкаПоОтчетам, ТаблицыОтчетов(), ПустаяКоллекцияТаблицОтчетов()));
	Запрос.УстановитьПараметр("Отчеты", Отчеты());
	Запрос.УстановитьПараметр("УпрощенныйИнтерфейсНастройкиПравДоступа", УправлениеДоступомСлужебный.УпрощенныйИнтерфейсНастройкиПравДоступа());
	Запрос.УстановитьПараметр("ПраваРолейРасширений", УправлениеДоступомСлужебный.ПраваРолейРасширений());
	
	ОтборПоПользователям = ОтборПоПользователям();
	Запрос.УстановитьПараметр("ЕстьОтборПоПользователям", ЗначениеЗаполнено(ОтборПоПользователям));
	Запрос.УстановитьПараметр("Пользователь", ОтборПоПользователям());
	
	АдресКартинкиПросмотр = Неопределено;
	АдресКартинкиРедактирование = Неопределено;
	АдресКартинкиСоздание = Неопределено;
	
	ЭтоФоновоеЗадание = ПолучитьТекущийСеансИнформационнойБазы().ПолучитьФоновоеЗадание() <> Неопределено;
	Если ЭтоФоновоеЗадание
		И ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.ВариантыОтчетов") 
		И КомпоновщикНастроек.Настройки.ДополнительныеСвойства.Свойство("АдресКартинкиПросмотр") Тогда
		АдресКартинкиПросмотр = КомпоновщикНастроек.Настройки.ДополнительныеСвойства.АдресКартинкиПросмотр;
		АдресКартинкиРедактирование = КомпоновщикНастроек.Настройки.ДополнительныеСвойства.АдресКартинкиРедактирование;
		АдресКартинкиСоздание = КомпоновщикНастроек.Настройки.ДополнительныеСвойства.АдресКартинкиСоздание;
	КонецЕсли;
	
	Запрос.УстановитьПараметр("КартинкаПросмотр", ПоместитьВоВременноеХранилище(БиблиотекаКартинок.Просмотр.ПолучитьДвоичныеДанные(), АдресКартинкиПросмотр));
	Запрос.УстановитьПараметр("КартинкаРедактирование", ПоместитьВоВременноеХранилище(БиблиотекаКартинок.Редактирование.ПолучитьДвоичныеДанные(), АдресКартинкиРедактирование));
	Запрос.УстановитьПараметр("КартинкаСоздание", ПоместитьВоВременноеХранилище(БиблиотекаКартинок.Создание.ПолучитьДвоичныеДанные(), АдресКартинкиСоздание));
	
	Возврат Запрос.Выполнить().Выгрузить();
	
КонецФункции

Функция ВключенаГруппировкаПоОтчетам()
	
	СписокПолей = Новый Массив;
	ЗаполнитьСписокПолейГруппировок(КомпоновщикНастроек.ПолучитьНастройки().Структура, СписокПолей);
	
	Возврат СписокПолей.Найти(Новый ПолеКомпоновкиДанных("Отчет")) <> Неопределено;
	
КонецФункции

// Параметры:
//  КоллекцияЭлементов - КоллекцияЭлементовСтруктурыНастроекКомпоновкиДанных
//  СписокПолей - Массив
//
Процедура ЗаполнитьСписокПолейГруппировок(КоллекцияЭлементов, СписокПолей)
	
	Для Каждого Элемент Из КоллекцияЭлементов Цикл
		Если (ТипЗнч(Элемент) = Тип("ГруппировкаКомпоновкиДанных")
			Или ТипЗнч(Элемент) = Тип("ГруппировкаТаблицыКомпоновкиДанных"))
			И Элемент.Использование Тогда
			Для Каждого Поле Из Элемент.ПоляГруппировки.Элементы Цикл
				Если ТипЗнч(Поле) = Тип("ПолеГруппировкиКомпоновкиДанных") Тогда
					Если Поле.Использование Тогда
						СписокПолей.Добавить(Поле.Поле);
					КонецЕсли;
				КонецЕсли;
			КонецЦикла;
			ЗаполнитьСписокПолейГруппировок(Элемент.Структура, СписокПолей);
		ИначеЕсли ТипЗнч(Элемент) = Тип("ТаблицаКомпоновкиДанных") И Элемент.Использование Тогда
			ЗаполнитьСписокПолейГруппировок(Элемент.Строки, СписокПолей);
			ЗаполнитьСписокПолейГруппировок(Элемент.Колонки, СписокПолей);
		КонецЕсли;
	КонецЦикла;
	
КонецПроцедуры

Функция ВыбранныйОтчет()
	
	ВыбранныеОтчеты = Новый Массив;
	Отбор = КомпоновщикНастроек.ПолучитьНастройки().Отбор;
	Для Каждого Элемент Из Отбор.Элементы Цикл 
		Если Элемент.Использование И Элемент.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("Отчет") Тогда
			Если Элемент.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно Тогда
				ВыбранныеОтчеты.Добавить(Элемент.ПравоеЗначение);
			Иначе
				Возврат Неопределено;
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;
	
	Если ВыбранныеОтчеты.Количество() = 1 Тогда
		Возврат ВыбранныеОтчеты[0];
	КонецЕсли;
	
	Возврат Неопределено;
	
КонецФункции

Функция ОтборПоПользователям()
	
	ПолеОтбора = КомпоновщикНастроек.ПолучитьНастройки().ПараметрыДанных.Элементы.Найти("Пользователь");
	ЗначениеОтбора = ПолеОтбора.Значение;
	Если Не ПолеОтбора.Использование Или Не ЗначениеЗаполнено(ЗначениеОтбора) Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	Отбор = ЗначениеОтбора;
	Если ТипЗнч(ЗначениеОтбора) <> Тип("СписокЗначений") Тогда
		Отбор = Новый СписокЗначений;
		Отбор.Добавить(ЗначениеОтбора);
	КонецЕсли;
	
	ТекстЗапроса =
	"ВЫБРАТЬ
	|	ГруппыПользователейСостав.Пользователь КАК Пользователь
	|ИЗ
	|	Справочник.ГруппыПользователей.Состав КАК ГруппыПользователейСостав
	|ГДЕ
	|	ГруппыПользователейСостав.Ссылка В(&Отбор)
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	Пользователи.Ссылка
	|ИЗ
	|	Справочник.Пользователи КАК Пользователи
	|ГДЕ
	|	Пользователи.Ссылка В(&Отбор)";
	
	Запрос = Новый Запрос(ТекстЗапроса);
	Запрос.УстановитьПараметр("Отбор", Отбор);
	Результат = Запрос.Выполнить().Выгрузить().ВыгрузитьКолонку("Пользователь");
	
	Возврат Результат;
	
КонецФункции

Процедура УстановитьОтборПоПользователям(НовыеНастройкиКД, СписокПользователей)
	
	ИмяПараметра = "Пользователь";
	
	Параметр = НовыеНастройкиКД.ПараметрыДанных.Элементы.Найти(ИмяПараметра);
	Если Параметр = Неопределено Тогда
		НовыеНастройкиКД = КомпоновщикНастроек.Настройки;
		Параметр = НовыеНастройкиКД.ПараметрыДанных.Элементы.Найти(ИмяПараметра);
	КонецЕсли;
	Параметр.Использование = Истина;
	Параметр.Значение = СписокПользователей;
	
КонецПроцедуры

#КонецОбласти

#Иначе
ВызватьИсключение НСтр("ru = 'Недопустимый вызов объекта на клиенте.'");
#КонецЕсли