<departments>
{
  for $deptno in doc("v-depts.xml")/departments/department/deptno
    let $emps := doc("v-emps.xml")/employees/employee[deptno[1]=$deptno]
   
    let $sals := $emps/salary
      let $dates := 
        for $date in distinct-values( ($sals/@tstart, $sals/@tend) )
        order by $date
        return $date
    let  $max := count( $dates )
    
    let $candidates := 
       for $tstart at $pos in $dates 
          let $sal := $sals[@tstart <= $tstart and $tstart < @tend], $tend := $dates[$pos+1]
        where $pos < $max
        return
          <maxsal tstart="{$tstart}" tend="{$tend}">{max($sal)}</maxsal>
    let $begin := min($dates)
    let $end := $dates[count($dates)]
    let $ans :=
      for $sal at $i in $candidates
      let $prev := $candidates[$i - 1]
        where $i=1 or ($sal != $prev)
      return
        <maxsal tstart="{$sal/@tstart}" tpreend="{$prev/@tend}">{xs:string($sal)}</maxsal>
    return
    <department deptno="{$deptno}"> 
    {
       if (count($ans) = 1) then
        <maxsal tstart="{$begin}" tend="{$end}">
        {
          $ans
        }
        </maxsal>
      else
        for $sal at $i in $ans
        let $next := $ans[$i + 1]
        return
        if ($i = count($ans)) then
          <maxsal tstart="{$sal/@tstart}" tend="{$end}">
          {
            xs:string($sal)
          }
          </maxsal>
        else
          <maxsal tstart="{$sal/@tstart}" tend="{$next/@tstart}">
          {
            xs:string($sal)
          }
          </maxsal>
    }
    </department>
}
</departments>