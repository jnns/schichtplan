select strftime("%w", Kal_Datum) as wochentag,
strftime("%d.%m.", Kal_Datum) as datum,
strftime("%H:%M", Kal_Zeit_von) as tresen_beginn,
strftime("%H:%M", Kal_Zeit_bis) as tresen_ende,
Tresen_Person.Mi_Name as Tresen,
Tresen_Vertretung.Mi_Name as Vertretung,
strftime("%H:%M", Ereignis.Von) as kurs_beginn,
strftime("%H:%M", Ereignis.Bis) as kurs_ende,
Kurse.Kurs_Bez as kurs,
Kurs_Person.Mi_Name as Kursleitung,
Ereignis.Anzahl as teilnehmer,
Ereignis.Achtung as achtung,
Bardienst.Kal_nein as vertretung_angefordert
from Bardienst
left join Ereignis on (Ereignis.Ereig_Kalendernr = Bardienst.Kal_lfd)
left join Kurse on (Kurse.Kurs_Lfd = Ereignis.Ereig_Nummer)
left join Mitarbeiter Kurs_Person on (Kurs_Person.Mit_lfd_Nr = Ereignis.Ereig_Mitarbeiter)
left join Mitarbeiter Tresen_Person on (Tresen_Person.Mit_lfd_Nr = Bardienst.Kal_Bardienst)
left join Mitarbeiter Tresen_Vertretung on (Tresen_Vertretung.Mit_lfd_Nr = Bardienst.Kal_Vertretung)
where Kal_Datum >= date('now') and Kal_Datum <= date('now', '+2 months')
order by Kal_Datum, Kal_Zeit_von, Von;
