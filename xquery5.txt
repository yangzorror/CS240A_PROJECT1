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