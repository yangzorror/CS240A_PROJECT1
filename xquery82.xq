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

<departments>
{
  for $dept in doc("v-emp_salary_rising_period.xml")//department
  return
  <department dept="{$dept/@deptno}" count = "{count($dept/emp)}">
  {
    let $dates :=
      for $date in distinct-values(($dept/emp/period/@start, $dept/emp/period/@end))
      order by $date
      return $date
    let $emps := 
       for $employee in doc("v-emps.xml")//employee
        where $employee/deptno[1] = $dept/@deptno
        return
        $employee
    let $num_emps := count($dept/emp)
    let $candidates :=
      for $date at $i in $dates
        where $i > 1
        let $prev := $dates[$i - 1]
        let $valid_period := $dept/emp/period[@start <= $prev and @end >= $date]
        let $valid_emp := 
          for $emp in $emps
            where $emp/deptno[1]/@tstart <= $prev and $emp/deptno[1]/@tend>=$date
          return $emp
        where count($valid_period) = count($valid_emp)
        let $end := local:convert($date)
        let $start := local:convert($prev)
      return
      <period tstart="{$prev}" tend="{$date}" count = "{count($valid_period)}" emp="{count($valid_emp)}" length="{$end - $start}">
      </period>
    let $max := max($candidates/@length)
    for $ans in $candidates
      where $ans/@length = $max
      return $ans
  }
  </department>
}
</departments>