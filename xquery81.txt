<departments>
{
  for $dept in doc("v-depts.xml")//deptno
    return 
    <department deptno="{$dept}">
    {
      for $emp in doc("v-emps.xml")//employee
      where $emp/deptno[1]=$dept
      return
      <emp empno="{$emp/empno[1]}">
      {
        let $rising :=
          for $sal at $i in $emp/salary
            order by $sal/@tstart
            let $prev := $emp/salary[$i - 1]
            where ($i>=2 and xs:integer($sal) >= xs:integer($prev)) or $i=1
          return $sal
        let $turner :=
          for $sal at $i in $emp/salary
            order by $sal/@tstart
            let $prev := $emp/salary[$i - 1]
            let $next := $emp/salary[$i + 1]
            where ($i>1 and $i < count($emp/salary) and xs:integer($sal) < xs:integer($prev) and xs:integer($sal) <= xs:integer($next))
          return $sal
        let $rising := $rising
        let $min := $rising[1]/@tstart
        let $max := $rising[count($rising)]/@tend
        
        let $starts := 
          for $sal at $i in $rising
            let $pre := $rising[$i - 1]
            where ($i>=2 and $pre/@tend != $sal/@tstart) or $i=1
           
          return
            if ($i=1) then
              <pair preend="000">
              {
                $sal/@tstart
              }
              </pair>
            else
              <pair preend="{$pre/@tend}">
              {
                $sal/@tstart
              }
              </pair>
              
        let $starts :=
          for $pair in $starts
          let $sal := $turner[@tend = $pair/@tstart]
         
        return
          if (count($sal) = 0) then
            $pair
          else
            <pair preend="{$pair/@preend}">
            {
              $sal/@tstart
            }
            </pair>
       return
            if (count($starts) = 1) then
              <period start="{$min}" end="{$max}">
              </period>
            else
              for $pair at $i in $starts
              let $next := $starts[$i + 1]
              return
                if ($i=count($starts)) then
                <period start="{$pair/@tstart}" end="{$max}">
                </period>
                else
                <period start="{$pair/@tstart}" end="{$next/@preend}">
                </period>
        
      }
      </emp>
          
    }
    </department>
}
</departments>