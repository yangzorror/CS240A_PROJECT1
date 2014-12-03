declare function local:accumulate($m as xs:integer)
as xs:integer
{
  let $months := (31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31)
  let $next := $m - 1
  return if ($m=0)
  then 0
  else $months[$m] + local:accumulate($next)
};
declare function local:convert($d as xs:date)
as xs:integer
{
  let $y := fn:year-from-date($d)
  let $m := fn:month-from-date($d)
  let $d := fn:day-from-date($d)
  let $ans := $y * 365 + xs:integer($y div 4) - xs:integer($y div 100) + xs:integer($y div 400) + $d
  
  return if ($m >= 2 and $y mod 4 = 0 and $y mod 100 != 0 or ($y mod 400 = 0 ))
  then $ans + 1+ local:accumulate($m)
  else $ans + local:accumulate($m)
};

for $emp in doc("v-emps.xml")/employees/employee
let $time := 0
let $name := concat($emp/firstname, ' ', $emp/lastname)
let $sal :=
  for $s in $emp/salary
  let $tend := 
    if (compare(xs:string($s/@tend), xs:string(fn:adjust-date-to-timezone( current-date( ), () ))) < 0) then
       $s/@tend
    else
      fn:adjust-date-to-timezone( current-date( ), () )
  let $end := local:convert($tend)
  let $start := local:convert($s/@tstart)
  order by $end - $start descending
  return
  <salary tstart="{$s/@tstart}" tend="{$tend}">
  {
    xs:integer($s)
  }
  </salary>

return 
<result name="{$name}" empno="{$emp/empno[1]}">
{
  $sal[1]
}
</result>