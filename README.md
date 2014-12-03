Project1 Report
====
Chunzhi Yang 604308880
----
[Question 1](#a_1) | [Question 2](#a_2) | [Question 3](#a_3) | [Question 4](#a_4) | [Question 5](#a_5)|[Question 6](#a_6) | [Question 7](#a_7) | [Question 8](#a_8)
****



<a name="a_1"></a>
###Question 1
**Question:**
> Selection and Temporal Projection. Retrieve the employment history of employee "Kyoichi Maliniak" (i.e., the departments where she worked and the periods during which she worked there).

**Solution:**
> The idea is pretty straight forward.  First, we select employee whose name is "Kyoichi Maliniak".  Second, we select department whose deptno equals to those of "Kyoichi Maliniak".  Then we print those departments and the time when Kyoichi Maliniak worked there.



**Code:**


	let $x :=
	  for $emp in doc("v-emps.xml")/employees/employee
	  where $emp/firstname[1]="Kyoichi" and $emp/lastname[1]="Maliniak"
	  return $emp
	for $deptno in $x/deptno
	
	  for $dept in doc("v-depts.xml")/departments/department
	  where $dept/deptno[1] = $deptno
	  
	return
	<department tstart="{$deptno/@tstart}" tend="{$deptno/@tend}" deptno="{$deptno}">
	{
	  $dept/deptname
	}
	</department>


****
<a name="a_2"></a>
###Question 2
**Question:**
> Temporal Snapshot. Retrieve the name,  salary and department of  each employee who, on 1991-01-06 was making less than $52000.

**Solution:**
> First, we check every salary entry of each employee.  If it meets the condition (overlapped 1991-01-06 and less than $52000), we select the deptno corresponding to the time period.  Finally, we print the department info.

**Code:**


	for $emp in doc("v-emps.xml")/employees/employee
	let $name := concat($emp/firstname, ' ', $emp/lastname)
	for $x in $emp/salary
		let $end := $x/@tend
		let $start := $x/@tstart
	for $dept in $emp/deptno
		let $dend := $dept/@tend
		let $dstart := $dept/@tstart
	where $x < 52000 and 
		compare($end, "1991-01-06") >= 0 and 
		compare($start, "1991-01-06") <= 0 and 
		compare($dend, "1991-01-06") >= 0 and 
		compare($dstart, "1991-01-06") <= 0
		
	group by $emp
		for $y in doc("v-depts.xml")/departments/department
	where $y/deptno = $dept
	return 
		<result name="{distinct-values($name)}" 
			department="{distinct-values($y/deptname)}">
			{$x}
		</result>
		
****
<a name="a_3"></a>
###Question 3
**Question:**

> Temporal Slicing. For all departments, show their history in the period starting on 1988-05-01 and ending 1998-05-06.

**Solution:**
> First, we select every child of each department.  If the time of the element overlapped with (1988-05-01 to 1998-05-06), we just print them.

**Code:**


	for $y in doc("v-depts.xml")/departments/department
	let $result := 
	  for $i in $y/*
	    let $start := $i/@tstart
	    let $end := $i/@tend
	    where not(
		    compare($start, "1998-05-06")>0 or 
		    compare($end, "1988-05-01") < 0
		    )
	  return $i
	return <result>{$result}</result>

****
<a name="a_4"></a>
###Question 4
**Question:**
> Duration: For each employee, show the longest period during which he/she went with no change in salary and his/her salary during that time.

**Solution:**
> For this question, I assume for each employee each salary element does not equal to other.  I just order the salary elements by the length of time and select the first one.

**Code:**

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

****
<a name="a_5"></a>
###Question 5
**Question:**
> Temporal Join. For each employee show  his/her empno, title,   deptno,  deptname  throughout his/her employment history.

** Solution:**
> First, we select each employee.  Second, we select corresponding departments and find the element whose time interval overlaps with that of employee/deptno.  Then, we print them out.

**Code:**


	declare function local:min( $d1 as xs:string, $d2 as xs:string ) as xs:date
	{
		if( xs:date($d1)>xs:date($d2) )
		then
			xs:date($d2)
		else
			xs:date($d1)
	};
	
	declare function local:max( $d1 as xs:string, $d2 as xs:string ) as xs:date
	{
	    if( xs:date($d1)>xs:date($d2) )
	    then
	        xs:date($d1)
	    else
	        xs:date($d2)
	};
	
	declare function local:now( ) as xs:string
	{
		xs:string( fn:adjust-date-to-timezone( current-date( ), () ) )
	};
	
	declare function local:slice( $element as element(), 
								 $start as xs:string, $stop as xs:string ) as attribute()*
	{
	  attribute tstart {local:max($start,$element/@tstart)},
	    attribute tend   {local:min($stop,$element/@tend)},
		$element/@*[name(.)!="tend" and name(.)!="tstart"]
	};
	
	declare function local:print($elements as element()*) as element()* {
	  for $e in $elements
	    return $e
	};
	
	<employees>
	{
	  for $emp in doc("v-emps.xml")/employees/employee
	  return element {
	    node-name($emp)
	  }
	  {
	    local:slice( $emp, '1900-01-01', local:now() ),
	    local:print(($emp/empno, $emp/firstname, $emp/lastname, $emp/title, $emp/deptno)),
	    <department>{
	      for
	        $deptno
	          in $emp/deptno
	      let $managers := 
	        for $manager
	          in doc("v-depts.xml")//
	            department[deptno=$deptno]/mgrno[not(@tstart > $deptno/@tend or @tend < $deptno/@tstart)]
	        return $manager
	      let $deptnames :=
	        for $deptname
	          in doc("v-depts.xml")//
	            department[deptno=$deptno]/deptname[not(@tstart > $deptno/@tend or @tend < $deptno/@tstart)]
	        return $deptname
	      return  local:print(($deptnames, $managers))
	    }
	    </department>
	  }
	}
	</employees>

****
<a name="a_6"></a>
###Question 6
**Question:**
> Temporal Count: For each department, show the history of its employee count.

**Solution:**
> The key to this question is to split the time interval to show the change of employee count.  For each department, I sort each start date and end date of each employee.  Then, I iterate the sorted time to get the time interval.  
> For each interval, I count the number of employee and print them.

**Code:**

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

****
<a name="a_7"></a>
###Question 7
**Question:**
> For each department show the history of the  maximum salary for the employees in that department.

**Solution:**
> This question is similar to Question 6.  
> First, we need to get all the interval.  I select all the salary element corresponding to each department.  Then, I sort all the start time and end time of the salary elements.  By iterating the sorted times, I can get each interval and max salary corresponding to that interval.
>Second, which is not similar to Question 6, is that I notice there are lots of duplicates in the result after the first step.  Thus, we need to combine those continued intervals with same value.  The method is that I iterate the result from first step, if the current value is the same with the previous interval, I just skip it.  Otherwise I keep track it.  After we got all the intervals which value does not equal to the previous one.  We can just iterate them and print the final result.

**Code:**

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

****
<a name="a_8"></a>
###Question 8
**Question:**
> Rising: For each department print the maximal periods during which the salaries of all the employees in the department was rising.

**Solution:**
> There are two steps.  The first step is to generate the period for each employee during which the salary is rising.  The second step is to find the maximal periods during which the salaries of all the employees in the department is rising.
> I stored the result of the first step as v-emp_salary_rising_period.xml.  The second step will use this data.
> Since the second step is really similar to the last two questions, I only explain the first step which is quite tricky.
> By iterating the salary of each employee, I find the salaries whose value is larger than the previous one.  Also, I find all the salaries whose value is lower than the previous one and the next one.  These salary could be the start of one rising period.  Thus, I combine the two types of salaries and find the longest period.

**Code:**

**Part 1**


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

**Part 2**

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