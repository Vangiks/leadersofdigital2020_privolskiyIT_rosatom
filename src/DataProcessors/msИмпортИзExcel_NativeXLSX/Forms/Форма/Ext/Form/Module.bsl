﻿
//___m.s.__20140317___DNovoselov___

// импорт данных их Excel через XML, т.е. из файлов Excel формата Office Open XML  (xlsx, xlsm)
// пока только импорт данных, т.е. результат = неформатированный табличный документ с данными + соответствие область - массив массивов значений колонок областей


////////////////////////////////////////////////////////////////////////////////
// СЛУЖЕБНЫЕ ПРОЦЕДУРЫ ВЫПОЛНЯЕМЫЕ НА СервереБезКонтеста

////////////////////////////////////////////////////////////////////////////////
// СЛУЖЕБНЫЕ ПРОЦЕДУРЫ ВЫПОЛНЯЕМЫЕ НА Сервере

////////////////////////////////////////////////////////////////////////////////
// СЛУЖЕБНЫЕ ПРОЦЕДУРЫ ВЫПОЛНЯЕМЫЕ НА Клиенте

////////////////////////////////////////////////////////////////////////////////
// ОБРАБОТЧИКИ СОБЫТИЙ ФОРМЫ НА Сервере

&НаСервере
Процедура ЗагрузитьНаСервере(АдресДД)
	
	ДД = ПолучитьИзВременногоХранилища(АдресДД);
	
	ИмяФайлаВрем = ПолучитьИмяВременногоФайла(Расширение);
	ДД.Записать(ИмяФайлаВрем);
	
	//
	
	Обработка = РеквизитФормыВЗначение("Объект");
	
	СоответствиеИмпортируемыхОбластей = Новый Соответствие;
	ТД = Обработка.ЗагрузитьМетодом_NativeXLSX(ИмяФайлаВрем, ИмяЛиста, СоответствиеИмпортируемыхОбластей);
	
	ТабличныйДокумент.Очистить();
	ТабличныйДокумент.Вывести(ТД);
	
	УдалитьФайлы(ИмяФайлаВрем); //___m.s.__20140407___DNovoselov___
	
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// ОБРАБОТЧИКИ СОБЫТИЙ ФОРМЫ НА Клиенте

////////////////////////////////////////////////////////////////////////////////
// ОБРАБОТЧИКИ КОМАНД ФОРМЫ

&НаКлиенте
Процедура Загрузить(Команда)
	
	// проверяем наличие самого файла и его расширение
	
	Файл = Новый Файл(ИмяФайла);
	//Если НЕ Файл.Существует() Тогда
	//	Сообщить("Файл '" + ИмяФайла + "' не найден!");
	//	Возврат;
	//КонецЕсли;
	
	Расширение = Файл.Расширение;
	Если НЕ ВРег(Расширение) = ".XLSX" И НЕ ВРег(Расширение) = ".XLSM" Тогда
		Сообщить("Файл с расширением '" + Расширение + "' не может быть загружен методом Native XLSX!");
		Возврат;
	КонецЕсли;
	
	//// проверяем указание листа
	//
	//// ...
	//
	
	ДД = Новый ДвоичныеДанные(Файл.ПолноеИмя);
	АдресДД = ПоместитьВоВременноеХранилище(ДД, УникальныйИдентификатор);
	
	ЗагрузитьНаСервере(АдресДД);
	
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// ОБРАБОТЧИКИ СОБЫТИЙ РЕКВИЗИТОВ ФОРМЫ (НА Клиенте)

&НаКлиенте
Процедура ИмяФайлаНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
	ДиалогСохраненияФайла = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.Открытие);
	
	ДиалогСохраненияФайла.ПолноеИмяФайла = ИмяФайла;
	ДиалогСохраненияФайла.Фильтр = "Таблица Excel 2007 (*.xlsx,*.xlsm)|*.xlsx;*.xlsm";
	ДиалогСохраненияФайла.Заголовок = "Выберите имя файла";
	
	//Если ДиалогСохраненияФайла.Выбрать() Тогда
	//	ИмяФайла = ДиалогСохраненияФайла.ПолноеИмяФайла;
	//КонецЕсли;
	
    ОповещениеВыбор = Новый ОписаниеОповещения("ВыборФайла", ЭтотОбъект);
    
    ДиалогСохраненияФайла.Показать(ОповещениеВыбор);	
	
КонецПроцедуры


&НаКлиенте
Процедура ВыборФайла(ВыбранныеФайлы, ДополнительныеПараметры) Экспорт
    
    Если ВыбранныеФайлы <> Неопределено И ВыбранныеФайлы.Количество() > 0 Тогда
        Сообщить("Файл выбран!");
		ИмяФайла = ВыбранныеФайлы[0];//ВыбранныеФайлы.ПолноеИмяФайла;
    Иначе
        Сообщить("Файл не выбран!");
    КонецЕсли;
    
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// ОБРАБОТЧИКИ СОБЫТИЙ РЕКВИЗИТОВ ТАБЛИЧНОЙ ЧАСТИ "ИМЯ ТЧ"(НА Клиенте)

////////////////////////////////////////////////////////////////////////////////
// ДАЛЕЕ СЛЕДУЮТ ОБРАБОТЧИКИ ПОДКЛЮЧАЕМЫХ ВНЕШНИХ ПОДСИСТЕМ




////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

// оригинал с http://infostart.ru/public/225624/
//   SBS: Загрузка из EXCEL в 1С /3+1 метод/. Чтение файла XLSX средствами 1С

//// Метод "NativeXLSX" (1C ЧтениеXML).
//// Преобразует текст формата XML (файл типа XLSX) в таблицу значений,
//// при этом колонки таблицы формируются на основе описания в XML.
////
//// Параметры:
////      ФайлEXCEL - Полное имя файла (путь к файлу с именем файла и расширением)
////      ИмяНомерЛиста - Структура Имя и Номер выбранного листа файла EXCEL.
////      СтрокаЗаголовка (по умолчанию = 1) - Номер строки EXCEL, в которой расположены заголовки колонок.
////          Не используется.
////      В обработке 1-я строка анализируется для сопоставления колонок EXCEL с реквизитами 1С (справочники, докуметны, регистры).
////      НачСтрока (по-умолчанию = 0) - Номер начальной строки, начиная с которой считываются данные из EXCEL.
////      КонСтрока (по-умолчанию = 0) - Номер конечной строки, которой заканчиваются считываемые данные из EXCEL.
////          Если НачСтрока=0 и КонСтрока=0, то считывается вся таблица, находящаяся на листе EXCEL.
////      КолвоСтрокExcel - Количество строк на листе "ИмяЛиста" EXCEL. Возвращается в вызываемую процедуру.
////
//// Возвращаемые значения:
////      ТаблицаРезультат - Результат считывания с листа "ИмяНомерЛиста" EXCEL.
////
//&НаСервере
//Функция ЗагрузитьМетодом_NativeXLSX(Знач ФайлEXCEL, Знач ИмяНомерЛиста, Знач СтрокаЗаголовка = 1, Знач НачСтрока = 0, Знач КонСтрока = 0, КолвоСтрокExcel = 0) Экспорт
//	Перем ZIPКаталог, SheetX;
//	Перем ФайлИмяЛиста, ФайлНомерЛиста, КолвоКолонокExcel, НомерСтроки, ЗначениеЯчейки, ИмяКолонки, ИмяКолонкиБезЦифр, ИндексКолонки,  ШиринаКолонки, ДлинаСтроки, КоличествоСлужебныхКолонок;
//	Перем МассивИменКолонокXLSX, МассивSharedStrings, МассивNumFmtId, СоответствиеNumFmtIdFormatCode;
//	Перем ЭтоНачалоДанных, ТипЗначения, ФорматЯчейки, ИндексФормата, ФорматСтиля;
//	Перем ТаблицаРезультат, НоваяСтрока, ОпределитьКоличествоСтрок;
//	ФайлНомерЛиста  = ИмяНомерЛиста;
//	ФайлНомерЛиста = ?(ФайлНомерЛиста = 0, 1, ФайлНомерЛиста);
//	ОпределитьКоличествоСтрок = (НачСтрока = 0 И КонСтрока = 0);
//	ZIPКаталог = КаталогВременныхФайлов() + "XLSX\";
//	Файл = ПолучитьОбъектФайл(ФайлEXCEL, Истина);
//	Если Файл = Неопределено Тогда
//		Сообщить("Невозможно загрузить данные с листа, т.к. невозможно открыть для чтения файл:
//		|" + ФайлEXCEL);
//		Возврат Новый ТаблицаЗначений;
//	КонецЕсли;
//	Если НЕ ВРег(Файл.Расширение) = ".XLSX" Тогда
//		Возврат Новый ТаблицаЗначений;
//	КонецЕсли;
//	КолвоКолонокExcel = ФайлExcelПолучитьКоличествоКолонокНаЛисте_1CXML_XLSX(ФайлEXCEL, ФайлИмяЛиста, ФайлНомерЛиста);
//	// Создание результирующей таблицы, в которую будут записываться считанные из EXCEL данные.
//	ТаблицаРезультат = Новый ТаблицаЗначений;
//	// Формирование колонок результирующей таблицы.
//	// "НомерСтроки" - для наглядности и удобства.
//	// В зависимости от разрабатываемой обработки.
//	// "Сопоставлено" - может быть другим.
//	// Здесь же могут быть добавлены другие колонки, не формируемые из содержимого файла EXCEL.
//	ТаблицаРезультат.Колонки.Добавить("НомерСтроки", Новый ОписаниеТипов("Число"), "№", 4);
//	ТаблицаРезультат.Колонки.Добавить("Сопоставлено", Новый ОписаниеТипов("Булево"), "Сопоставлено", 1);
//	КоличествоСлужебныхКолонок = 2;
//	Для ит = 1 ПО КолвоКолонокExcel Цикл
//		ИмяКолонки = "N" + ит;
//		Колонка = ТаблицаРезультат.Колонки.Добавить(ИмяКолонки);
//	КонецЦикла;
//	SheetX = Новый ЧтениеXML;
//	SheetX.ОткрытьФайл(ZIPКаталог + "XL\WorkSheets\Sheet" + ФайлНомерЛиста + ".xml");
//	МассивИменКолонокXLSX = Новый Массив;
//	ПолучитьМассивИменКолонокXLSX(КолвоКолонокExcel, МассивИменКолонокXLSX, -1);
//	СоответствиеNumFmtIdFormatCode = Новый Соответствие;
//	МассивNumFmtId = ПолучитьМассивМассивNumFmtId(ZIPКаталог + "XL\", СоответствиеNumFmtIdFormatCode);
//	МассивSharedStrings = ПолучитьМассивSharedStrings(ZIPКаталог + "XL\");
//	ЭтоНачалоДанных = Ложь;
//	// Считать очередной узел XML.
//	Пока SheetX.Прочитать() Цикл
//		Если ВРег(SheetX.Имя) = "SHEETDATA" И SheetX.ТипУзла = ТипУзлаXML.НачалоЭлемента Тогда
//			ЭтоНачалоДанных = Истина;
//			Прервать;
//		КонецЕсли;
//	КонецЦикла;
//	Если НЕ ЭтоНачалоДанных Тогда
//		Возврат Новый ТаблицаЗначений;
//	КонецЕсли;
//	// Считать очередной узел XML.
//	НомерСтроки = 0;
//	Пока SheetX.Прочитать() Цикл
//		Если ВРег(SheetX.Имя) = "SHEETDATA" И SheetX.ТипУзла = ТипУзлаXML.КонецЭлемента Тогда
//			Прервать;   // Окончание данных.
//		КонецЕсли;
//		Если ВРег(SheetX.Имя) = "ROW" И SheetX.ТипУзла = ТипУзлаXML.НачалоЭлемента Тогда
//			НомерСтроки = НомерСтроки + 1;
//			Если НЕ НачСтрока = 0 И НЕ НомерСтроки = 1 И НомерСтроки < НачСтрока Тогда
//				Продолжить;
//			КонецЕсли;
//			НоваяСтрока = ТаблицаРезультат.Добавить();
//			НоваяСтрока.НомерСтроки = НомерСтроки;
//			Пока SheetX.Прочитать() Цикл    // Считаем колонки строки EXCEL.
//				Если ВРег(SheetX.Имя) = "ROW" Тогда
//					Прервать;
//				КонецЕсли;
//				Если ВРег(SheetX.Имя) = "SHEETDATA" И SheetX.ТипУзла = ТипУзлаXML.КонецЭлемента Тогда
//					Прервать;   // Окончание данных.
//				КонецЕсли;
//				Если ВРег(SheetX.Имя) = "C" И SheetX.ТипУзла = ТипУзлаXML.НачалоЭлемента Тогда
//					ИмяКолонки = SheetX.ЗначениеАтрибута("r");
//					ИмяКолонкиБезЦифр = ЗаменитьОдниСимволыДругими("0123456789", ИмяКолонки, "");
//					ТипЗначения = SheetX.ЗначениеАтрибута("t");
//					ФорматЯчейки = SheetX.ЗначениеАтрибута("s");
//					ИндексКолонки = МассивИменКолонокXLSX.Найти(ИмяКолонкиБезЦифр);
//					ИндексКолонки = ?(ИндексКолонки = Неопределено, КоличествоСлужебныхКолонок-1, ИндексКолонки+КоличествоСлужебныхКолонок-1);
//					SheetX.Прочитать();
//					Если ВРег(SheetX.Имя) = "V"  ИЛИ ВРег(SheetX.Имя) = "F" Тогда   // "V" - Значение, "F" - Формула.
//						Если ВРег(SheetX.Имя) = "F" Тогда
//							Пока НЕ ВРег(SheetX.Имя) = "V" Цикл
//								SheetX.Прочитать();
//							КонецЦикла;
//						КонецЕсли;
//						SheetX.Прочитать();
//						Если ВРег(SheetX.Имя) = "#TEXT" Тогда
//							ЗначениеЯчейки = SheetX.Значение;
//							ФорматСтиля = "";
//							Если (НЕ ФорматЯчейки = "" И НЕ ФорматЯчейки = Неопределено) Тогда
//								Попытка
//									ИндексФормата = Число(ФорматЯчейки);
//									ФорматСтиля = СоответствиеNumFmtIdFormatCode.Получить(МассивNumFmtId[ИндексФормата]);
//								Исключение
//									ФорматСтиля = "";
//								КонецПопытки;
//							КонецЕсли;
//							Если ЗначениеЗаполнено(ЗначениеЯчейки) Тогда
//								Если ТипЗначения = Неопределено ИЛИ ВРег(ТипЗначения) = "N" Тогда
//									Попытка
//										Значение1 = Число(ЗначениеЯчейки);
//									Исключение
//										Значение1 = ЗначениеЯчейки;
//									КонецПопытки;
//									ЗначениеЯчейки = Значение1;
//									Если (ФорматСтиля = "" ИЛИ ФорматСтиля = Неопределено) Тогда
//										// ФорматСтиля = Неопределено - Атрибут "s" отсутствует.
//										// MS Office (2010) может не формировать в xml-файле описание стиля форматирования для ячейки.
//										// LibreOffice (4.1.5) формирует в xml-файле необходимые описания стиля форматирования ячейки.
//									КонецЕсли;
//									Если ТипЗнч(ЗначениеЯчейки) = Тип("Число") Тогда
//										// ПРОЦЕНТ.
//										Если ЭтоПроцентXLSX(ЗначениеЯчейки, ФорматСтиля) Тогда
//											ЗначениеЯчейки = ЗначениеЯчейки * 100;
//											// ВРЕМЯ.
//										ИначеЕсли (ЗначениеЯчейки < 1 И ЭтоВремяXLSX(ЗначениеЯчейки, ФорматСтиля)) Тогда
//											ЗначениеЯчейки = КонвертироватьЧислоXLSXвДатуВремя(ЗначениеЯчейки);
//											// ДАТА.
//										ИначеЕсли (ЗначениеЯчейки = Цел(ЗначениеЯчейки) И ЭтоДатаXLSX(ЗначениеЯчейки, ФорматСтиля)) Тогда
//											ЗначениеЯчейки = КонвертироватьЧислоXLSXвДату(ЗначениеЯчейки);
//											// ЧИСЛО.
//										ИначеЕсли ТипЗначения = Неопределено
//											ИЛИ ( ЭтоЧислоXLSX(ЗначениеЯчейки, ФорматСтиля)
//											И НЕ ЭтоВремяXLSX(ЗначениеЯчейки, ФорматСтиля)
//											И НЕ ЭтоДатаXLSX(ЗначениеЯчейки, ФорматСтиля) )
//											Тогда
//											// Без дальнейших преобразований.
//										Иначе
//											// Прочие форматы.
//										КонецЕсли;
//									Иначе
//										// ЧИСЛО.
//										Если Прав(ЗначениеЯчейки, 5) = "E-003" Тогда
//											УдалитьПоследнийСимволВСтроке(ЗначениеЯчейки, 5);
//											Попытка
//												ЗначениеЯчейки = Число(ЗначениеЯчейки);
//											Исключение
//											КонецПопытки;
//											// ЧИСЛО.
//										ИначеЕсли Прав(ЗначениеЯчейки, 3) = "E-3" Тогда
//											УдалитьПоследнийСимволВСтроке(ЗначениеЯчейки, 3);
//											Попытка
//												ЗначениеЯчейки = Число(ЗначениеЯчейки);
//											Исключение
//											КонецПопытки;
//											// ВРЕМЯ.
//										ИначеЕсли ЭтоВремяXLSX(ЗначениеЯчейки, ФорматСтиля) Тогда
//											ЗначениеЯчейки = КонвертироватьЧислоXLSXвДатуВремя(ЗначениеЯчейки);
//										Иначе
//											// Прочие форматы.
//										КонецЕсли;
//									КонецЕсли;
//								ИначеЕсли ВРег(ТипЗначения) = "S" Тогда
//									// МассивSharedStrings может быть пустым.
//									Попытка
//										ЗначениеЯчейки = МассивSharedStrings[Число(SheetX.Значение)];
//									Исключение
//										ЗначениеЯчейки = "";
//									КонецПопытки;
//									ЗначениеЯчейки = СокрЛП(ЗначениеЯчейки);
//								ИначеЕсли ВРег(ТипЗначения) = "STR" Тогда
//									// Формула. Оставляем "как есть".
//								КонецЕсли;
//							КонецЕсли;
//							ИмяКолонки = "N"+ИндексКолонки;
//							НоваяСтрока[ИмяКолонки] = ЗначениеЯчейки;
//							// Используется при формировании таблицы на форме обработки.
//							ШиринаКолонки = ТаблицаРезультат.Колонки[ИмяКолонки].Ширина;
//							ДлинаСтроки = СтрДлина(СокрЛП(ЗначениеЯчейки));
//							ТаблицаРезультат.Колонки[ИмяКолонки].Ширина = ?(ШиринаКолонки < ДлинаСтроки, ДлинаСтроки, ШиринаКолонки);
//						КонецЕсли;
//					КонецЕсли;
//				КонецЕсли;
//			КонецЦикла;
//			Если ((НЕ КонСтрока = 0 И (НомерСтроки + 1) > КонСтрока)
//				ИЛИ (НЕ КолвоСтрокExcel = 0  И (НомерСтроки + 1) > КолвоСтрокExcel)) Тогда
//				Прервать;   // Окончание диапазона считываемых данных.
//			КонецЕсли;
//		КонецЕсли;
//	КонецЦикла;
//	// Завершение работы.
//	// Закрытие Объектов.
//	SheetX.Закрыть();
//	УдалитьКолонкиСНулевойШириной(ТаблицаРезультат);
//	Если ОпределитьКоличествоСтрок Тогда
//		КолвоСтрокExcel = ТаблицаРезультат.Количество();
//	КонецЕсли;
//	Возврат ТаблицаРезультат;
//КонецФункции

//&НаСервере
//Процедура ПолучитьМассивИменКолонокXLSX(Знач КолвоКолонокExcel, МассивИменКолонокXLSX, Индекс=-1)
//	Перем Алфавит, ит, Буква;
//	Алфавит = РазложитьСтрокуВМассивПодстрок("A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z", ",");
//	Если МассивИменКолонокXLSX.Количество() > КолвоКолонокExcel Тогда
//		Возврат;
//	КонецЕсли;
//	Если Индекс > Алфавит.Количество()-1 Тогда
//		Возврат;
//	КонецЕсли;
//	Буква = ?(Индекс = -1, "", Алфавит[Индекс]);
//	Для ит = 0 ПО Алфавит.Количество()-1 Цикл
//		МассивИменКолонокXLSX.Добавить(Буква+Алфавит[ит]);
//		Если МассивИменКолонокXLSX.Количество() >= КолвоКолонокExcel Тогда
//			Возврат;
//		КонецЕсли;
//	КонецЦикла;
//	Если МассивИменКолонокXLSX.Количество() > КолвоКолонокExcel Тогда
//		Возврат;
//	Иначе
//		Индекс = Индекс + 1;
//		ПолучитьМассивИменКолонокXLSX(КолвоКолонокExcel, МассивИменКолонокXLSX, Индекс);
//	КонецЕсли;
//	Возврат;
//КонецПроцедуры

//&НаСервере
//Функция ПолучитьМассивМассивNumFmtId(Каталог, СоответствиеNumFmtIdFormatCode)
//	Перем Файл, Styles;
//	Перем МассивNumFmtId, ит;
//	МассивNumFmtId = Новый Массив;
//	СоответствиеNumFmtIdFormatCode = Новый Соответствие;
//	Файл = Новый Файл(Каталог + "Styles.xml");
//	Если НЕ Файл.Существует() Тогда
//		Возврат МассивNumFmtId;
//	КонецЕсли;
//	Styles = Новый ЧтениеXML;
//	Styles.ОткрытьФайл(Каталог + "Styles.xml");
//	Пока Styles.Прочитать() Цикл
//		Если ВРег(Styles.Имя) = ВРег("numFmt") И Styles.ТипУзла = ТипУзлаXML.НачалоЭлемента Тогда
//			СоответствиеNumFmtIdFormatCode.Вставить(Styles.ЗначениеАтрибута("numFmtId"), ВРег(Styles.ЗначениеАтрибута("formatCode")));
//		КонецЕсли;
//		Если ВРег(Styles.Имя) = ВРег("cellXfs") Тогда
//			Пока Styles.Прочитать() Цикл
//				Если ВРег(Styles.Имя) = ВРег("xf") И Styles.ТипУзла = ТипУзлаXML.НачалоЭлемента Тогда
//					МассивNumFmtId.Добавить(Styles.ЗначениеАтрибута("numFmtId"));
//				КонецЕсли;
//			КонецЦикла;
//		КонецЕсли;
//	КонецЦикла;
//	// Завершение работы.
//	// Закрытие Объектов.
//	Styles.Закрыть();
//	// Проверка сопоставления кодов массива и соответствия.
//	// MS Office (2010) может не формировать в xml-файле описание стиля форматирования для ячейки.
//	// LibreOffice (4.1.5) формирует в xml-файле необходимые описания стиля форматирования ячейки.
//	Для Каждого ит ИЗ МассивNumFmtId Цикл
//		Если СоответствиеNumFmtIdFormatCode.Получить(ит) = Неопределено Тогда
//			// Сообщить("В описании отсутствует стиль форматирования для кода " + ит);
//			Если ит = "0" Тогда // Стандарт для числа (Целое число).
//				СоответствиеNumFmtIdFormatCode.Вставить(ит, "GENERAL");
//			ИначеЕсли ит = "9" ИЛИ ит = "10" Тогда  // Форматы для % ("0%", "0.00%").
//				СоответствиеNumFmtIdFormatCode.Вставить(ит, "0%");
//			ИначеЕсли ит = "14" ИЛИ ит = "16" Тогда // Форматы для даты.
//				СоответствиеNumFmtIdFormatCode.Вставить(ит, "DD.MM.YYYY");
//			КонецЕсли;
//		КонецЕсли;
//	КонецЦикла;
//	Возврат МассивNumFmtId;
//КонецФункции

//&НаСервере
//Функция ПолучитьМассивSharedStrings(Каталог)
//	Перем Файл, SharedStrings;
//	Перем МассивSharedStrings;
//	// Если в файле EXCEL не содержится значений, имеющих тип "СТРОКА", то файл "SharedStrings.xml" не формируется.
//	МассивSharedStrings = Новый Массив;
//	Файл = Новый Файл(Каталог + "SharedStrings.xml");
//	Если НЕ Файл.Существует() Тогда
//		Возврат МассивSharedStrings;
//	КонецЕсли;
//	SharedStrings = Новый ЧтениеXML;
//	SharedStrings.ОткрытьФайл(Каталог + "SharedStrings.xml");
//	Пока SharedStrings.Прочитать() Цикл
//		Если ВРег(SharedStrings.Имя) = "#TEXT" Тогда
//			МассивSharedStrings.Добавить(SharedStrings.Значение);
//		КонецЕсли;
//	КонецЦикла;
//	// Завершение работы.
//	// Закрытие Объектов.
//	SharedStrings.Закрыть();
//	Возврат МассивSharedStrings;
//КонецФункции

//&НаСервере
//Функция ЭтоЧислоXLSX(Знач ЗначениеЯчейки, Знач ФорматСтиля)
//	Если ( ВРег(ФорматСтиля) = "GENERAL"
//		ИЛИ ВРег(ФорматСтиля) = "STANDARD"
//		ИЛИ Найти(ФорматСтиля, "0") > 0
//		ИЛИ Прав(ЗначениеЯчейки, 5) = "E-003"
//		ИЛИ Прав(ЗначениеЯчейки, 3) = "E-3" )
//		Тогда
//		Возврат Истина;
//	КонецЕсли;
//	Возврат Ложь;
//КонецФункции

//&НаСервере
//Функция ЭтоПроцентXLSX(Знач ЗначениеЯчейки, Знач ФорматСтиля)
//	Если ( Найти(ФорматСтиля, "%") > 0 )
//		Тогда
//		Возврат Истина;
//	КонецЕсли;
//	Возврат Ложь;
//КонецФункции

//&НаСервере
//Функция ЭтоДатаXLSX(Знач ЗначениеЯчейки, Знач ФорматСтиля)
//	Если ( Найти(ФорматСтиля, "DD") > 0
//		ИЛИ Найти(ФорматСтиля, "MM") > 0
//		ИЛИ Найти(ФорматСтиля, "YY") > 0
//		ИЛИ Найти(ФорматСтиля, "QQ") > 0
//		ИЛИ Найти(ФорматСтиля, "WW") > 0 )
//		Тогда
//		Возврат Истина;
//	КонецЕсли;
//	Возврат Ложь;
//КонецФункции

//&НаСервере
//Функция ЭтоВремяXLSX(Знач ЗначениеЯчейки, Знач ФорматСтиля)
//	Если ( Найти(ФорматСтиля, "HH:") > 0
//		ИЛИ Найти(ФорматСтиля, "[HH]:") > 0
//		ИЛИ Найти(ФорматСтиля, "[H]:") > 0
//		ИЛИ Найти(ФорматСтиля, "MM:") > 0
//		ИЛИ Найти(ФорматСтиля, ":SS") > 0
//		ИЛИ Прав(ЗначениеЯчейки, 5) = "E-005"
//		ИЛИ Прав(ЗначениеЯчейки, 3) = "E-5"
//		ИЛИ Прав(ЗначениеЯчейки, 3) = "E-4" )
//		Тогда
//		Возврат Истина;
//	КонецЕсли;
//	Возврат Ложь;
//КонецФункции

//&НаСервере
//Функция КонвертироватьЧислоXLSXвДату(Знач Число)
//	Перем Дата1900, Разница, ДатаРезультат;
//	Дата1900 = Дата("19000101");
//	Разница = Число - 2;    // Excel ошибочно считает 1900-й год високосным.
//	Разница = ?(Разница < 0, Разница = 0, Разница);
//	ДатаРезультат = Дата1900 + Разница * 24 * 60 * 60;
//	Возврат ДатаРезультат;
//КонецФункции

//&НаСервере
//Функция КонвертироватьЧислоXLSXвДатуВремя(Знач Число)
//	Перем Делитель, КВоСекунд, КВоСекунд1;
//	Перем ВремяРезультат;
//	// 0,0000115740740740741 = 1 сек.
//	// 1                     = 24 часа 00 мин 00 сек.
//	Если ТипЗнч(Число) = Тип("Строка") Тогда
//		// MS Office, LibreOffice.
//		Если Прав(Число, 5) = "E-005" ИЛИ Прав(Число, 3) = "E-5" Тогда
//			Делитель = 100000;
//		ИначеЕсли Прав(Число, 3) = "E-4" Тогда
//			Делитель = 10000;
//		ИначеЕсли Прав(Число, 3) = "E-3" Тогда
//			Делитель = 1000;
//		КонецЕсли;
//		КВоСекунд = Цел(Число(Лев(Число,15)) / Делитель / 0.0000115740740740741) + 1;
//	Иначе
//		// LibreOffice.
//		КВоСекунд1= Число * 100000 / 1.15740740740741;
//		КВоСекунд = Цел(КВоСекунд1);
//		КВоСекунд = ?(КВоСекунд1 > 10, КВоСекунд + 1, КВоСекунд);
//	КонецЕсли;
//	ВремяРезультат = Дата("19000101000000") + КВоСекунд;
//	Возврат ВремяРезультат;
//КонецФункции

//&НаСервере
//Функция ПолучитьОбъектФайл(Знач ФайлEXCEL, РаспаковатьXLSX = Ложь) Экспорт
//	Перем Файл, objFSO, objFile, XLSXРаспакован;
//	Если НЕ ЗначениеЗаполнено(ФайлEXCEL) Тогда
//		Возврат Неопределено;
//	КонецЕсли;
//	Файл = Новый Файл(ФайлEXCEL);
//	Если НЕ Файл.Существует() Тогда
//		Сообщить("Файл не существует:
//		|" + ФайлEXCEL);
//		Возврат Неопределено;
//	КонецЕсли;
//	// Проверка: Занят ли файл другим процессом?
//	objFSO = Новый COMОбъект("Scripting.FileSystemObject");
//	Попытка
//		objFSO.MoveFile(ФайлEXCEL, ФайлEXCEL);
//		objFile = objFSO.GetFile(ФайлEXCEL);
//	Исключение
//		objFile = Неопределено;
//		objFSO = Неопределено;
//		Сообщить("Ошибка открытия файла/Файл занят другой программой:
//		|" + ФайлEXCEL);
//		Возврат Неопределено;
//	КонецПопытки;
//	objFSO = Неопределено;
//	Если ВРег(Файл.Расширение) = ".XLSX" И РаспаковатьXLSX Тогда
//		// Распаковка файла XLSX во временный каталог.
//		XLSXРаспакован = РаспаковатьXLSXвКаталогВременныхФайлов(ФайлEXCEL);
//		Если НЕ XLSXРаспакован Тогда
//			Сообщить("Ошибка распаковки файла/Файл имеет другой формат (не xlsx):
//			|" + ФайлEXCEL);
//			Возврат Неопределено;
//		КонецЕсли;
//	КонецЕсли;
//	Возврат Файл;
//КонецФункции

//&НаСервере
//Функция РаспаковатьXLSXвКаталогВременныхФайлов(ФайлEXCEL)
//	Перем ZIPФайл, ZIPКаталог;
//	Попытка
//		ZIPКаталог = КаталогВременныхФайлов() + "XLSX\";
//		УдалитьФайлы(ZIPКаталог);
//		ZIPФайл = Новый ЧтениеZipФайла;
//		ZIPФайл.Открыть(ФайлEXCEL);
//		ZIPФайл.ИзвлечьВсе(ZIPКаталог, РежимВосстановленияПутейФайловZIP.Восстанавливать);
//		Возврат Истина;
//	Исключение
//		Возврат Ложь;
//	КонецПопытки;
//	Возврат Истина;
//КонецФункции

//&НаСервере
//Функция ФайлExcelПолучитьКоличествоКолонокНаЛисте_1CXML_XLSX(ФайлДанных, ФайлИмяЛиста, ФайлНомерЛиста)
//	Перем ZIPКаталог, SheetX;
//	Перем ПозицияТ;
//	Перем КолвоКолонокExcel;
//	ФайлНомерЛиста = ?(ФайлНомерЛиста = 0, 1, ФайлНомерЛиста);
//	ZIPКаталог = КаталогВременныхФайлов() + "XLSX\";
//	КолвоКолонокExcel = 0;
//	Файл = ПолучитьОбъектФайл(ФайлДанных, Истина);
//	Если Файл = Неопределено Тогда
//		СписокЛистов = Новый СписокЗначений;
//		Сообщить("Невозможно получить номер листа, т.к. невозможно открыть для чтения файл:
//		|" + ФайлДанных);
//		Возврат 0;
//	КонецЕсли;
//	Если ВРег(Файл.Расширение) = ".XLSX" Тогда
//		SheetX = Новый ЧтениеXML;
//		SheetX.ОткрытьФайл(ZIPКаталог + "XL\WorkSheets\Sheet" + ФайлНомерЛиста + ".xml");
//		Подсчет = Ложь;
//		// Считать очередной узел XML.
//		Пока SheetX.Прочитать() Цикл
//			// Подсчет по 1-ой строке.
//			Если ВРег(SheetX.Имя) = "ROW" Тогда
//				Если SheetX.ТипУзла = ТипУзлаXML.НачалоЭлемента Тогда
//					// Начало отсчета.
//					Подсчет = Истина;
//				ИначеЕсли SheetX.ТипУзла = ТипУзлаXML.КонецЭлемента Тогда
//					// Окончание отсчета.
//					Прервать;
//				КонецЕсли;
//			КонецЕсли;
//			Если Подсчет И ВРег(SheetX.Имя) = "C" И SheetX.ТипУзла = ТипУзлаXML.НачалоЭлемента Тогда
//				КолвоКолонокExcel = КолвоКолонокExcel + 1;
//			КонецЕсли;
//		КонецЦикла;
//	КонецЕсли;
//	// Завершение работы.
//	// Закрытие Объектов.
//	SheetX.Закрыть();
//	Возврат КолвоКолонокExcel;
//КонецФункции

//// Выполняет замену символов в строке.
////
//// Параметры:
////  ЗаменяемыеСимволы - Строка - строка символов, каждый из которых требует замены;
////  Строка            - Строка - исходная строка, в которой требуется замена символов;
////  СимволыЗамены     - Строка - строка символов, на каждый из которых нужно заменить символы параметра ЗаменяемыеСимволы.
////
////  Возвращаемое значение:
////   Строка - строка после замены символов.
////
////  Примечание: функция предназначена для простых случаев, например, для замены латиницы на похожие кириллические символы.
////              Функция не анализирует повторную замену символов, поэтому такой вызов:
////               ЗаменитьОдниСимволыДругими("кр", "карета", "гз") вернёт слово "газета", а
////               ЗаменитьОдниСимволыДругими("кр", "карета", "рк") не вернёт слово "ракета".
////
//&НаСервере
//Функция ЗаменитьОдниСимволыДругими(ЗаменяемыеСимволы, Строка, СимволыЗамены) Экспорт
//	Результат = Строка;
//	Для НомерСимвола = 1 По СтрДлина(ЗаменяемыеСимволы) Цикл
//		Результат = СтрЗаменить(Результат, Сред(ЗаменяемыеСимволы, НомерСимвола, 1), Сред(СимволыЗамены, НомерСимвола, 1));
//	КонецЦикла;
//	Возврат Результат;
//КонецФункции

//// Функция "расщепляет" строку на подстроки, используя заданный
////      разделитель. Разделитель может иметь любую длину.
////      Если в качестве разделителя задан пробел, рядом стоящие пробелы
////      считаются одним разделителем, а ведущие и хвостовые пробелы параметра Стр
////      игнорируются.
////      Например,
////      РазложитьСтрокуВМассивПодстрок(",один,,,два", ",") возвратит массив значений из пяти элементов,
////      три из которых - пустые строки, а
////      РазложитьСтрокуВМассивПодстрок(" один   два", " ") возвратит массив значений из двух элементов
////
////  Параметры:
////      Стр -           строка, которую необходимо разложить на подстроки.
////                      Параметр передается по значению.
////      Разделитель -   строка-разделитель, по умолчанию - запятая.
////
////  Возвращаемое значение:
////      массив значений, элементы которого - подстроки
////
//&НаСервере
//Функция РазложитьСтрокуВМассивПодстрок(Знач Стр, Разделитель = ",")
//	МассивСтрок = Новый Массив();
//	Если Разделитель = " " Тогда
//		Стр = СокрЛП(Стр);
//		Пока 1 = 1 Цикл
//			Поз = Найти(Стр, Разделитель);
//			Если Поз = 0 Тогда
//				МассивСтрок.Добавить(СокрЛП(Стр));
//				Возврат МассивСтрок;
//			КонецЕсли;
//			МассивСтрок.Добавить(СокрЛП(Лев(Стр, Поз - 1)));
//			Стр = СокрЛ(Сред(Стр, Поз));
//		КонецЦикла;
//	Иначе
//		ДлинаРазделителя = СтрДлина(Разделитель);
//		Пока 1 = 1 Цикл
//			Поз = Найти(Стр, Разделитель);
//			Если Поз = 0 Тогда
//				Если (СокрЛП(Стр) <> "") Тогда
//					МассивСтрок.Добавить(СокрЛП(Стр));
//				КонецЕсли;
//				Возврат МассивСтрок;
//			КонецЕсли;
//			МассивСтрок.Добавить(СокрЛП(Лев(Стр,Поз - 1)));
//			Стр = Сред(Стр, Поз + ДлинаРазделителя);
//		КонецЦикла;
//	КонецЕсли;
//КонецФункции

//// Удаляет из строки указанное количество символов справа.
////
//// Параметры:
////  Текст         - Строка - строка, в которой необходимо удалить последние символы;
////  ЧислоСимволов - Число  - количество удаляемых символов.
////
//&НаСервере
//Процедура УдалитьПоследнийСимволВСтроке(Текст, ЧислоСимволов)
//	Текст = Лев(Текст, СтрДлина(Текст) - ЧислоСимволов);
//КонецПроцедуры

//&НаСервере
//Процедура УдалитьКолонкиСНулевойШириной(ТаблицаРезультат)
//	Перем МассивПустыхКолонок;
//	// Найдем пустые колонки.
//	МассивПустыхКолонок = Новый Массив;
//	Для Каждого Колонка ИЗ ТаблицаРезультат.Колонки Цикл
//		Если Колонка.Ширина = 0 Тогда
//			МассивПустыхКолонок.Добавить(Колонка.Имя);
//		КонецЕсли;
//	КонецЦикла;
//	// Удалим пустые колонки.
//	Для Каждого ПустаяКолонка ИЗ МассивПустыхКолонок Цикл
//		ТаблицаРезультат.Колонки.Удалить(ПустаяКолонка);
//	КонецЦикла;
//КонецПроцедуры


