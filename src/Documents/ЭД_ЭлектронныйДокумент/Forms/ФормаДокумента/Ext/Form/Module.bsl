﻿
#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	//Если ЗначениеЗаполнено(Объект.Ссылка) Тогда
	//	ЭтаФорма.ТолькоПросмотр = Объект.Выгружен;
	//КонецЕсли;
	Объект.Автор = ?(ЗначениеЗаполнено(Объект.Автор), Объект.Автор, Пользователи.АвторизованныйПользователь());
	
КонецПроцедуры

&НаСервере
Процедура ПриЧтенииНаСервере(ТекущийОбъект)
	
	// СтандартныеПодсистемы.УправлениеДоступом
	Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.УправлениеДоступом") Тогда
		МодульУправлениеДоступом = ОбщегоНазначения.ОбщийМодуль("УправлениеДоступом");
		МодульУправлениеДоступом.ПриЧтенииНаСервере(ЭтотОбъект, ТекущийОбъект);
	КонецЕсли;
	// Конец СтандартныеПодсистемы.УправлениеДоступом
	
КонецПроцедуры

&НаСервере
Процедура ПослеЗаписиНаСервере(ТекущийОбъект, ПараметрыЗаписи)

	// СтандартныеПодсистемы.УправлениеДоступом
	Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.УправлениеДоступом") Тогда
		МодульУправлениеДоступом = ОбщегоНазначения.ОбщийМодуль("УправлениеДоступом");
		МодульУправлениеДоступом.ПослеЗаписиНаСервере(ЭтотОбъект, ТекущийОбъект, ПараметрыЗаписи);
	КонецЕсли;
	// Конец СтандартныеПодсистемы.УправлениеДоступом

КонецПроцедуры

#КонецОбласти


&НаКлиенте
Процедура Выгрузить(Команда)
	
	
	СкачатьФайл();
	
	Объект.Выгружен = Истина;
	Объект.ДатаВыгрузки = ТекущаяДата();
	
	//Записать();
	
	
КонецПроцедуры


&НаСервере
Функция Сериализовать(ОбъектСериализации) 
	ДеревоВОбъектеXDTO = СериализаторXDTO.ЗаписатьXDTO(ОбъектСериализации); 
	МойXML = Новый ЗаписьXML; 
	МойXML.УстановитьСтроку();
	ФабрикаXDTO.ЗаписатьXML(МойXML, ДеревоВОбъектеXDTO); 
	Возврат МойXML.Закрыть(); 
КонецФункции


&НаКлиенте
Процедура СкачатьФайл()

	ИмяФайла = "export.xml";
	Если Не ЗначениеЗаполнено(ИмяФайла) Тогда
		Возврат;
	КонецЕсли;
	
	АдресФайлаДляСкачивания = Адрес;
	
	Если Не ЭтоАдресВременногоХранилища(АдресФайлаДляСкачивания) Тогда
		АдресФайлаДляСкачивания = ПолучитьАдресФайлаДляСкачивания();
	КонецЕсли;
	
	Если ЭтоАдресВременногоХранилища(АдресФайлаДляСкачивания) Тогда
		ПараметрыДиалога = Новый ПараметрыДиалогаПолученияФайлов;
		ПараметрыДиалога.Заголовок = НСтр("ru = 'Выберите путь для сохранения файла'; en = 'Select the path to save the file'");
		
		НачатьПолучениеФайлаССервера(АдресФайлаДляСкачивания, ИмяФайла, ПараметрыДиалога);
	КонецЕсли;

КонецПроцедуры

&НаСервере
Функция ПолучитьАдресФайлаДляСкачивания()

	ИмяФайла = ПолучитьИмяВременногоФайла("xml");
	
	ТекстФайла = Сериализовать(Объект.ОстаткиПоСчетам.Выгрузить()); 
	ТекстФайла = ТекстФайла + Символы.ПС;
	ТекстФайла = ТекстФайла + Сериализовать(Объект.ФинансовыеСделки.Выгрузить());
	
	ТекстовыйФайл = Новый ТекстовыйДокумент;
	ТекстовыйФайл.УстановитьТекст(ТекстФайла);
	ТекстовыйФайл.Записать(ИмяФайла);
	
	ДвоичныеДанные = Новый ДвоичныеДанные(ИмяФайла);
	
	Адрес = ПоместитьВоВременноеХранилище(ДвоичныеДанные, ЭтаФорма.УникальныйИдентификатор);
	
	УдалитьФайлы(ИмяФайла);
	
	Возврат Адрес;

КонецФункции

&НаКлиенте
Процедура Загрузить(Команда)
	
	ПараметрыДиалога = Новый ПараметрыДиалогаПомещенияФайлов;
	ПараметрыДиалога.МножественныйВыбор = Ложь;
	ПараметрыДиалога.Заголовок = НСтр("ru = 'Выберите файл'; en = 'Select file'");
   	ПараметрыДиалога.Фильтр = НСтр("ru = 'Файл экселя'; en = 'Excel file'") + " (*.xls, *.xlsx)|*.xls;*.xlsx|";
	
    ЗавершениеОбратныйВызов = Новый ОписаниеОповещения("ЗавершениеОбратныйВызов", ЭтотОбъект);
	ПередНачаломОбратныйВызов = Новый ОписаниеОповещения("ПередНачаломОбратныйВызов", ЭтотОбъект);
    НачатьПомещениеФайлаНаСервер(ЗавершениеОбратныйВызов, , ПередНачаломОбратныйВызов,, ПараметрыДиалога, ЭтаФорма.УникальныйИдентификатор);

	
КонецПроцедуры

&НаКлиенте
Процедура ЗавершениеОбратныйВызов(ОписаниеПомещенногоФайла, ДополнительныеПараметры) Экспорт

	Если ОписаниеПомещенногоФайла = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	//Запись.ИмяФайла = ОписаниеПомещенногоФайла.СсылкаНаФайл.Имя;
	//Запись.РазмерФайла = ОписаниеПомещенногоФайла.СсылкаНаФайл.Размер();
	Адрес = ОписаниеПомещенногоФайла.Адрес;
	
	ЗагрузитьИзЭкселя(ОписаниеПомещенногоФайла.СсылкаНаФайл.Расширение);

КонецПроцедуры

&НаКлиенте
Процедура ПередНачаломОбратныйВызов(ПомещаемыйФайл, ОтказОтПомещенияФайла, ДополнительныеПараметры) Экспорт

	МегабайтВБайтах = 100000000;
	Если ПомещаемыйФайл.Размер() > МегабайтВБайтах Тогда
		ОтказОтПомещенияФайла = Истина;
		ТекстСообщения = СтрШаблон(НСтр("ru = 'Отказ. Загружаемый файл «%1» имеет размер более 1 мегабайта';
		|en = 'Failure. The uploaded file «%1» is larger than 1 megabyte'"), ПомещаемыйФайл.Имя);
		
		Сообщение = Новый СообщениеПользователю;
		Сообщение.Текст = ТекстСообщения;
		Сообщение.Сообщить();
		ОтказОтПомещенияФайла = Истина;
		
		//ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения,,,, ОтказОтПомещенияФайла);
	Иначе
		ПоказатьОповещениеПользователя(НСтр("ru = 'Загрузка файла'; en = 'Uploading file'"),, ПомещаемыйФайл.Имя);
	КонецЕсли;  

КонецПроцедуры

&НаСервере
Процедура ЗагрузитьИзЭкселя(Расширение)
	
	Файл = ПолучитьИзВременногоХранилища(Адрес);
	ИмяФайла = ПолучитьИмяВременногоФайла(Расширение);
	Файл.Записать(ИмяФайла);
	
	ТабДок = Новый ТабличныйДокумент;
	ТабДок.Прочитать(ИмяФайла);
	
	Объект.ОстаткиПоСчетам.Очистить();
	Строка = 12;
	Пока ЗначениеЗаполнено(ТабДок.Область("R"+Строка+"C2").Текст) Цикл
		
		ИДОрганизации = ТабДок.Область("R"+Строка+"C2").Текст;
		
		БИКБанка = ТабДок.Область("R"+Строка+"C7").Текст;
		
		Комментарий = ТабДок.Область("R"+Строка+"C9").Текст;
		
		Валюта = ТабДок.Область("R"+Строка+"C10").Текст;
		
		Сумма = ТабДок.Область("R"+Строка+"C11").Текст;
		
		НоваяСтрока = Объект.ОстаткиПоСчетам.Добавить();
		НоваяСтрока.Организация = Справочники.Организации.НайтиПоРеквизиту("ID", ИДОрганизации);
		НоваяСтрока.Банк = Справочники.КлассификаторБанков.НайтиПоКоду(БИКБанка);
		НоваяСтрока.Валюта = Справочники.Валюты.НайтиПоНаименованию(Валюта);
		
		НоваяСтрока.Комментарий = Комментарий;
		НоваяСтрока.Сумма = Число(Сумма);		
		
		Строка = Строка + 1;
	КонецЦикла;
	
	Пока ЗначениеЗаполнено(ТабДок.Область("R"+Строка+"C2").Текст) Цикл
		
	КонецЦикла;


	УдалитьФайлы(ИмяФайла);
	
	
КонецПроцедуры

&НаКлиенте
Процедура СохранитьВЭксель(Команда)
	
	Если Модифицированность Тогда
		
		Оповещение = Новый ОписаниеОповещения("СохранитьВЭксельПослеОтветаНаВопрос", ЭтотОбъект);
		ПоказатьВопрос(Оповещение, "Документ был изменен и будет записан. Продолжить?", РежимДиалогаВопрос.ДаНет);
		
	Иначе
		СохранитьВЭксельПродолжение();
		
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура СохранитьВЭксельПослеОтветаНаВопрос(Ответ, ДополнительныеПараметры) Экспорт
	
	Если Ответ = КодВозвратаДиалога.Да Тогда
		
		Если Записать() Тогда
			
			СохранитьВЭксельПродолжение();
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура СохранитьВЭксельПродолжение()
	
	ДиалогСохраненияФайла = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.Сохранение);
	ДиалогСохраненияФайла.МножественныйВыбор = Ложь;
	ДиалогСохраненияФайла.Фильтр = "Книга Excel (.xlsx)|*.xlsx"; // (.xls)|*.xls";
	
	ДополнительныеПараметры = Новый Структура;
	ДополнительныеПараметры.Вставить("ТабДокРезультат",       СформироватьТабДокПоМакету(Объект.Ссылка));
	ДополнительныеПараметры.Вставить("ДиалогСохраненияФайла", ДиалогСохраненияФайла);
	
	ОписаниеОповещенияДиалогаВыбора = Новый ОписаниеОповещения(
		"СохранитьВЭксельЗавершение", ЭтотОбъект, ДополнительныеПараметры);
	ФайловаяСистемаКлиент.ПоказатьДиалогВыбора(ОписаниеОповещенияДиалогаВыбора, ДиалогСохраненияФайла);
	
КонецПроцедуры

&НаКлиенте
Процедура СохранитьВЭксельЗавершение(ВыбранныеФайлы, ДополнительныеПараметры) Экспорт
	
	Если ВыбранныеФайлы = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	ТабДокРезультат = ДополнительныеПараметры.ТабДокРезультат;
	ИмяФайла        = ДополнительныеПараметры.ДиалогСохраненияФайла.ПолноеИмяФайла;
	
	ДополнительныеПараметры.Вставить("ИмяФайла", ИмяФайла);
	ОписаниеОповещения = Новый ОписаниеОповещения("ПослеСохраненияВЭксель", ЭтотОбъект, ДополнительныеПараметры);
	
	Если ТипЗнч(ТабДокРезультат) = Тип("Массив") Тогда // книга с листами
		Если ТабДокРезультат.Количество() = 0 Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				НСтр("ru = 'Не найдено ни одного бланка'"));
				
			Возврат;
		КонецЕсли;
		
		КнигаЭксель = Новый ПакетОтображаемыхДокументов;
		
		Для Каждого ТекЛистТабДок Из ТабДокРезультат Цикл
			ЛистКниги = КнигаЭксель.Состав.Добавить(ПоместитьВоВременноеХранилище(ТекЛистТабДок.Значение));
			ЛистКниги.Наименование = ТекЛистТабДок.Ключ;
		КонецЦикла;
		
		КнигаЭксель.НачатьЗапись(ОписаниеОповещения, ИмяФайла, ТипФайлаПакетаОтображаемыхДокументов.XLSX); //XLS);
		
	Иначе
		ТабДокРезультат.НачатьЗапись(ОписаниеОповещения, ИмяФайла, ТипФайлаТабличногоДокумента.XLSX); //XLS);
		
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПослеСохраненияВЭксель(Результат, ДополнительныеПараметры) Экспорт
	
	Если Результат <> Истина Тогда
		Возврат;
	КонецЕсли;
	
	Если ДополнительныеПараметры.Свойство("ИмяФайла") Тогда
		ТекстСообщения =
			СтрШаблон(
				НСтр("ru = 'Файл %1 сохранен'"),
				ДополнительныеПараметры.ИмяФайла);
		
	Иначе
		Возврат;
	КонецЕсли;
	
	ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения);
	
КонецПроцедуры

&НаСервереБезКонтекста
Функция СформироватьТабДокПоМакету(Ссылка)
	
	ТабДок = Новый ТабличныйДокумент;
	Макет  = Документы.ЭД_ЭлектронныйДокумент.ПолучитьМакет("Макет");
	
	Запрос = Новый Запрос;
	Запрос.Текст =
		"ВЫБРАТЬ
		|	ЭД_ЭлектронныйДокумент.Дата КАК Дата,
		|	ЭД_ЭлектронныйДокумент.Организация КАК Организация,
		|	Организации.ИНН КАК ИНН,
		|	ЭД_ЭлектронныйДокумент.Автор КАК Автор,
		|	Пользователи.Телефон КАК Телефон,
		|	Пользователи.АдресЭлектроннойПочты КАК АдресЭлектроннойПочты
		|ИЗ
		|	Документ.ЭД_ЭлектронныйДокумент КАК ЭД_ЭлектронныйДокумент
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.Пользователи КАК Пользователи
		|		ПО ЭД_ЭлектронныйДокумент.Автор = Пользователи.Ссылка
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.Организации КАК Организации
		|		ПО ЭД_ЭлектронныйДокумент.Организация = Организации.Ссылка";
	
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	
	Выборка = Запрос.Выполнить().Выбрать();
	Выборка.Следующий();
	
	ОбластьШапка = Макет.ПолучитьОбласть("Шапка");
	ОбластьШапка.Параметры.Заполнить(Выборка);
	ОбластьШапка.Параметры.Дата = Формат(Выборка.Дата, "ДЛФ=DD");
	
	ТабДок.Вывести(ОбластьШапка);
	
	
	Запрос = Новый Запрос;
	Запрос.Текст =
		"ВЫБРАТЬ
		|	Организации.ID КАК ID,
		|	Организации.ИНН КАК ИНН,
		|	Организации.КПП КАК КПП,
		|	ЭД_ЭлектронныйДокументОстаткиПоСчетам.Организация КАК Организация,
		|	Организации.Тип КАК Тип,
		|	КлассификаторБанков.СВИФТБИК КАК БИК,
		|	ЭД_ЭлектронныйДокументОстаткиПоСчетам.Банк КАК Банк,
		|	ЭД_ЭлектронныйДокументОстаткиПоСчетам.Комментарий КАК Комментарий,
		|	ЭД_ЭлектронныйДокументОстаткиПоСчетам.Валюта КАК Валюта,
		|	ЭД_ЭлектронныйДокументОстаткиПоСчетам.Сумма КАК СуммаОстаток
		|ИЗ
		|	Документ.ЭД_ЭлектронныйДокумент.ОстаткиПоСчетам КАК ЭД_ЭлектронныйДокументОстаткиПоСчетам
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.Организации КАК Организации
		|		ПО ЭД_ЭлектронныйДокументОстаткиПоСчетам.Организация = Организации.Ссылка
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.КлассификаторБанков КАК КлассификаторБанков
		|		ПО ЭД_ЭлектронныйДокументОстаткиПоСчетам.Банк = КлассификаторБанков.Ссылка
		|ГДЕ
		|	ЭД_ЭлектронныйДокументОстаткиПоСчетам.Ссылка = &Ссылка
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ЭД_ЭлектронныйДокументФинансовыеСделки.Организация КАК Организация,
		|	ФинансовыеСделки.ВидДоговора КАК ВидДоговора,
		|	ФинансовыеСделки.ДатаЗаключения КАК ДатаЗаключения,
		|	ФинансовыеСделки.ДатаНачалаДействия КАК ДатаНачалаДействия,
		|	ФинансовыеСделки.ДатаОкончания КАК ДатаОкончания,
		|	ФинансовыеСделки.РасчетнаяСтавка КАК РасчетнаяСтавка,
		|	ФинансовыеСделки.Валюта КАК Валюта,
		|	ЭД_ЭлектронныйДокументФинансовыеСделки.Сумма КАК СуммаДоговора
		|ИЗ
		|	Документ.ЭД_ЭлектронныйДокумент.ФинансовыеСделки КАК ЭД_ЭлектронныйДокументФинансовыеСделки
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.ФинансовыеСделки КАК ФинансовыеСделки
		|		ПО ЭД_ЭлектронныйДокументФинансовыеСделки.Сделка = ФинансовыеСделки.Ссылка
		|ГДЕ
		|	ЭД_ЭлектронныйДокументФинансовыеСделки.Ссылка = &Ссылка";
	
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	
	РезультатЗапроса = Запрос.ВыполнитьПакет();
	
	тзОстаткиПоСчетам  = РезультатЗапроса[0].Выгрузить();
	тзФинансовыеСделки = РезультатЗапроса[1].Выгрузить();
	
	тзОстаткиПоСчетам.Индексы.Добавить("Организация");
	тзФинансовыеСделки.Индексы.Добавить("Организация");
	
	МассивОрганизаций = ОбщегоНазначенияКлиентСервер.СвернутьМассив(тзОстаткиПоСчетам.ВыгрузитьКолонку("Организация"));
	ОбщегоНазначенияКлиентСервер.ДополнитьМассив(МассивОрганизаций, тзФинансовыеСделки.ВыгрузитьКолонку("Организация"), Истина);
	
	ОбластьСтрокаОстаткиПоСчетам  = Макет.ПолучитьОбласть("Строка|ОстаткиПоСчетам");
	ОбластьСтрокаФинансовыеСделки = Макет.ПолучитьОбласть("Строка|ФинансовыеСделки");
	
	ОбластьСтрокаОстаткиПоСчетамПустая  = Макет.ПолучитьОбласть("Строка|ОстаткиПоСчетам");
	ОбластьСтрокаФинансовыеСделкиПустая = Макет.ПолучитьОбласть("Строка|ФинансовыеСделки");
	
	НомерСтроки = 1;
	СтруктураПоиска = Новый Структура;
	
	Для Каждого Организация Из МассивОрганизаций Цикл
		
		СтруктураПоиска.Вставить("Организация", Организация);
		
		СтрокиОстаткиПоСчетам  = тзОстаткиПоСчетам.НайтиСтроки(СтруктураПоиска);
		СтрокиФинансовыеСделки = тзФинансовыеСделки.НайтиСтроки(СтруктураПоиска);
		
		МаксИндексОстаткиПоСчетам  = СтрокиОстаткиПоСчетам.ВГраница();
		МаксИндексФинансовыеСделки = СтрокиФинансовыеСделки.ВГраница();
		
		МаксИндекс = Макс(МаксИндексОстаткиПоСчетам, МаксИндексФинансовыеСделки);
		
		Для Инд = 0 По МаксИндекс Цикл
			Если Инд <= МаксИндексОстаткиПоСчетам Тогда
				
				стрОстаткиПоСчетам = СтрокиОстаткиПоСчетам[Инд];
				
				ОбластьСтрокаОстаткиПоСчетам.Параметры.Заполнить(стрОстаткиПоСчетам);
				ВыводимаяОбласть = ОбластьСтрокаОстаткиПоСчетам;
				
			Иначе
				ВыводимаяОбласть = ОбластьСтрокаОстаткиПоСчетамПустая;
				
			КонецЕсли;
			
			ВыводимаяОбласть.Параметры.НомерСтроки = НомерСтроки;
			
			ТабДок.Вывести(ВыводимаяОбласть);
			
			
			Если Инд <= МаксИндексФинансовыеСделки Тогда
				
				стрФинансовыеСделки = СтрокиФинансовыеСделки[Инд];
				
				ОбластьСтрокаФинансовыеСделки.Параметры.Заполнить(стрФинансовыеСделки);
				ВыводимаяОбласть = ОбластьСтрокаФинансовыеСделки;
				
			Иначе
				ВыводимаяОбласть = ОбластьСтрокаФинансовыеСделкиПустая;
				
			КонецЕсли;
			
			ТабДок.Присоединить(ВыводимаяОбласть);
			
			НомерСтроки = НомерСтроки + 1;
			
		КонецЦикла;
	КонецЦикла;
	
	Возврат ТабДок;
	
КонецФункции

