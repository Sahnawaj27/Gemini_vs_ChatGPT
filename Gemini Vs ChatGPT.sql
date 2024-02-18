-- 1)What are the average scores for each capability on both the Gemini Ultra and GPT-4 models? --

select b.CapabilityID,c.CapabilityName,
round(avg(b.ScoreGemini),1) as Gemini_Score,
round(avg(b.ScoreGPT4),1) as GPT_Score
from benchmarks b join capabilities c 
on b.capabilityid=c.CapabilityID
group by 1,2;

-- 2)Which benchmarks does Gemini Ultra outperform GPT-4 in terms of scores? --

select BenchmarkName,
ScoreGemini,
ScoreGPT4
from benchmarks
where ScoreGemini > ScoreGPT4
order by 2 desc;

-- 3)What are the highest scores achieved by Gemini Ultra and GPT-4 for each benchmark in the Image capability? --

select c.CapabilityName,
max(b.ScoreGemini),
max(b.ScoreGPT4)
from benchmarks b join capabilities c 
on b.capabilityid=c.CapabilityID
where b.CapabilityID=5
group by 1;

-- 4)Calculate the percentage improvement of Gemini Ultra over GPT-4 for each benchmark? --

with cte as (select BenchmarkName,
ScoreGemini,
ScoreGPT4,
round(((ScoreGemini-ScoreGPT4)*100/ScoreGemini),2) as Improvement
from benchmarks)
select BenchmarkName,
Improvement
from cte
where Improvement is not null
order by 2 desc;

-- 5)Retrieve the benchmarks where both models scored above the average for their respective models? --

select BenchmarkName,
ScoreGemini,
ScoreGPT4
from benchmarks
where ScoreGemini > (select avg(ScoreGemini) from benchmarks) and
ScoreGPT4 > (select avg(ScoreGPT4) from benchmarks);

-- 6)Which benchmarks show that Gemini Ultra is expected to outperform GPT-4 based on the next score? --

select BenchmarkName
from (select BenchmarkName,
ScoreGemini,
lead(ScoreGemini) over (order by ScoreGemini) as gemini_next_score,
ScoreGPT4
from benchmarks
where ScoreGPT4 is not null) b
where gemini_next_score > ScoreGPT4;

-- 7)Classify benchmarks into performance categories based on score ranges? --

select BenchmarkName,
case when ScoreGemini >90 then "Excellent"
when ScoreGemini >80 then "Better"
else "Good" end as Gemini_Performance,
case when ScoreGPT4 >90 then "Excellent"
when ScoreGPT4 >80 then "Better"
else "Good" end as GPT4_Performance
from benchmarks;

-- 8) Retrieve the rankings for each capability based on Gemini Ultra scores? --

select b.Capabilityid,
c.CapabilityName, 
avg_ScoreGemini, 
Dense_Rank() over (order by avg_ScoreGemini desc) as Gemini_Rank
from (select Capabilityid,
round(avg(ScoreGemini),1) as avg_ScoreGemini
from benchmarks 
group by 1)b join capabilities c 
on b.capabilityid=c.CapabilityID;

-- 9)Convert the Capability and Benchmark names to uppercase? --

select upper(b.BenchmarkName) as BenchmarkName, 
upper(c.CapabilityName) as CapabilityName
from benchmarks b join capabilities c 
on b.capabilityid=c.CapabilityID;

-- 10) Can you provide the benchmarks along with their descriptions in a concatenated format? --

select concat(BenchmarkName, " - ", description) as Full_Details
from benchmarks;

