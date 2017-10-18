echo "ssh in deploy_host"
ssh deploy_host exit
echo "exit deploy_host"
echo "ssh in controller"
ssh controller exit
echo "exit controller"
echo "ssh in compute"
ssh compute exit
echo "exit compute"
echo "ssh in ceph1"
ssh ceph1 exit
echo "exit ceph1"
echo "ssh in ceph2"
ssh ceph2 exit
echo "exit ceph2"
echo "ssh in ecoh3"
ssh ceph3 exit
echo "exit ceph3"
