﻿
#Если НЕ Клиент И НЕ ВнешнееСоединение Тогда
	
Функция глЗначениеПеременной(Имя, НеКэшировать = Ложь) Экспорт
	
	Возврат ЭД_ОбщегоНазначения.ПолучитьЗначениеПеременной(Имя);
	
КонецФункции

#КонецЕсли

Функция ОбработатьПараметр(Параметр)
	мсвСтрокиСсылок = Новый Массив;
	Если ТипЗнч(Параметр) = Тип("Строка") И Лев(Параметр, 6)="e1cib/" Тогда
		мсвСтрокиСсылок.Добавить(Параметр);
		мсвПредставленияСсылок = ПолучитьПредставленияНавигационныхСсылок(мсвСтрокиСсылок);
		Если мсвПредставленияСсылок[0]<>Неопределено Тогда
			Параметр = мсвПредставленияСсылок[0].Текст;
		КонецЕсли;
	КонецЕсли;
	мсвСтрокиСсылок.Очистить();
	Возврат Параметр
КонецФункции

Функция ЗаменитьПараметрыВСтроке(Знач НачальнаяСтрока, Знач Параметр1, Знач Параметр2="", Знач Параметр3="") Экспорт 
	Параметр1 = ОбработатьПараметр(Параметр1);
	Параметр2 = ОбработатьПараметр(Параметр2);
	Параметр3 = ОбработатьПараметр(Параметр3);

	НачальнаяСтрока = СтрЗаменить(НачальнаяСтрока, "%1", Параметр1);
	НачальнаяСтрока = СтрЗаменить(НачальнаяСтрока, "%2", Параметр2);
	НачальнаяСтрока = СтрЗаменить(НачальнаяСтрока, "%3", Параметр3);	
	Возврат НачальнаяСтрока;
КонецФункции


