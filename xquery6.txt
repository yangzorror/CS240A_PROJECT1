<departments>
{
  for $deptno in doc( "v-depts.xml" )/departments/department/deptno
    let $deptnos := doc( "v-emps.xml" )//deptno[.=$deptno]
    let $dates   := 
      for $date in distinct-values( ($deptnos/@tstart, $deptnos/@tend) )
      order by $date
      return $date
    let  $num := count( $dates )
    return
      <department deptno = "{$deptno}">
      {
        for $tstart at $i in $dates 
          let $ans := $deptnos[@tstart <= $tstart and $tstart < @tend], $tend := $dates[$i+1]
        where $i < $num
        return
          <count tstart="{$tstart}" tend="{$tend}">{count($ans)}</count>
      } 
      </department>
}
</departments>