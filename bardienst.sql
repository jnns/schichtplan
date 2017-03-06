/* Anmeldung */
select
	date(Kal_Datum) as datum,
	strftime('%H:%M', Kal_Zeit_von) as von,
	strftime('%H:%M', Kal_Zeit_bis) as bis,
	mitarbeiter_1.Mi_Name as Dienst,
	mitarbeiter_2.Mi_Name as Vertretung,
	Kal_nein as vertretung_angefordert
from Bardienst
left join Mitarbeiter as mitarbeiter_1
	on (mitarbeiter_1.Mit_lfd_Nr = Bardienst.Kal_Bardienst)
left join Mitarbeiter as mitarbeiter_2
	on (mitarbeiter_2.Mit_lfd_Nr = Bardienst.Kal_Vertretung)
where
	date('now', '-3 days') <= datum and
	datum <= date('now', '+1 month')
order by datum, von, bis
