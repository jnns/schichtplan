select
	date(am) as datum,
	strftime('%H:%M', Von) as von,
	strftime('%H:%M', Bis) as bis,
	Kurs_Bez as Kurs,
	Anzahl as Teilnehmer,
	Pers as "Betreuung durch",
	Mi_Name as "erfasst durch"

from Ereignis
left join Kurse
on (Kurse.Kurs_Lfd = Ereignis.Ereig_Nummer)
left join Mitarbeiter
on (Mitarbeiter.Mit_lfd_Nr = Ereignis.Ereig_Mitarbeiter)
where
	date('now', '-2 months') <= datum and
	datum <= date('now', '+1 month')
order by datum, von, bis
