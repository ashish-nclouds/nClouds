#!/bin/bash

DATE=`date +"%Y%m%d-%H%M%S"`
LAST_LINE=`tail -n 1 main`
DIR="/media/ashish/Personal/GIT/mywork/learning_stuff/terraform/Backup/demo_dashboard_timeboard_02_script"
WIDGET="/media/ashish/Personal/GIT/mywork/learning_stuff/terraform/Backup/demo_dashboard_timeboard_02_script/widgets/"

echo "Welcome! create your dashboard using code"
read -p "Enter Dashboard Name: " DASHBOARD_NAME

echo "Enter Dashboard title"	
read -p "Enter title Name: " title_dashboard

if [ -f $DIR/main.tf ]
then
	mv $DIR/main.tf $DIR/main.tf.$DATE
else
	echo "......................"
fi

cp $DIR/terraform.t $DIR/terraform.tfvars

if [ -d "$DIR/backup" ]
then
	cp $DIR/main $DIR/backup/
else
	mkdir  $DIR/backup
	cp $DIR/main  $DIR/backup
fi


if [ "$LAST_LINE" == "}" ]
then
	sed '$d' $DIR/main >> $DIR/main.tf
else
	echo "continue selecting modules"
	sed -i  's/var.dashboard_name/'$DASHBOARD_NAME'/g' >> $DIR/main.tf
	cat $DIR/main.tf
fi

sed -i  's/var.dashboard_name/'$DASHBOARD_NAME'/g' $DIR/main.tf
sed -i  's/var.title_dashboard/'$title_dashboard'/g' $DIR/main.tf

echo "-------------------------------------------------------"
echo "Select the Modules:"
options=("rds_check_status" "rds_cpu_utilization" "rds_deadlock" "rds_disk_queue" "rds_queries" "rds_read_iops" "rds_read_latency" "rds_read_throughput" "rds_swap_usage" "rds_total_iops" "rds_volume_read_iops" "rds_volume_write_iops" "rds_write_iops" "rds_write_latency" "trace_mysql_query" "mysql_db_connection" "clear-screen" "help" "clear-directory" "done" "quit")
select opt in "${options[@]}" 
do
	case $opt in 
		"mysql_db_connection")
			echo "$opt"
			cat $WIDGET/mysql_db_connection >> $DIR/main.tf
		;;
		"rds_check_status")
			echo "$opt"
			cat $WIDGET/rds_check_status >> $DIR/main.tf
		;;
		"rds_cpu_utilization")
			echo "$opt"
			cat $WIDGET/rds_cpu_utilization >> $DIR/main.tf
		;;
		"rds_deadlock")
			echo "$opt"
			cat $WIDGET/rds_deadlock >> $DIR/main.tf
		;;
		"rds_disk_queue")
			echo "$opt"
			cat $WIDGET/rds_disk_queue >> $DIR/main.tf
		;;
		"rds_queries")
			echo "$opt"
			cat $WIDGET/rds_queries >> $DIR/main.tf
		;;
		"rds_read_iops")
			echo "$opt"
			cat $WIDGET/rds_read_iops >> $DIR/main.tf
		;;		
		"rds_read_latency")
			echo "$opt"
			cat $WIDGET/rds_read_latency >> $DIR/main.tf
		;;
		"rds_read_throughput")
			echo "$opt"
			cat $WIDGET/rds_read_throughput >> $DIR/main.tf
		;;
		"rds_swap_usage")
			echo "$opt"
			cat $WIDGET/rds_swap_usage >> $DIR/main.tf
		;;						
		"rds_total_iops")
			echo "$opt"
			cat $WIDGET/rds_total_iops >> $DIR/main.tf
		;;						
		"rds_volume_read_iops")
			echo "$opt"
			cat $WIDGET/rds_volume_read_iops >> $DIR/main.tf
		;;						
		"rds_volume_write_iops")
			echo "$opt"
			cat $WIDGET/rds_volume_write_iops >> $DIR/main.tf
		;;						
		"rds_write_iops")
			echo "$opt"
			cat $WIDGET/rds_write_iops >> $DIR/main.tf
		;;						
		"rds_write_latency")
			echo "$opt"
			cat $WIDGET/rds_write_latency >> $DIR/main.tf
		;;						
		"trace_mysql_query")
			echo "$opt"
			cat $WIDGET/trace_mysql_query >> $DIR/main.tf
		;;						
		"clear-screen")
			echo "Clear Screen"
			clear
		;;
		"help")
			echo "HELP"
		;;		
		"clear-directory")
			rm -rf $DIR/main.t*
			rm -rf $DIR/terraform.tfvars
		;;
		"done")
			cat $DIR/template >> $DIR/main.tf
            echo $LAST_LINE >> $DIR/main.tf
			echo -e "'main.tf' has been generated ...\n Now execute --- 'terraform plan -out <name>"
		break
		;;
		"quit")		
			echo "Restoring  Backup, try creating dashboard again"
			mv $DIR/main.tf $DIR/main.tf.$DATE
		break
		;;
	*)
	esac
echo "exiting Case"
done

sudo chown -R <owner>:<group> $DIR/*
sudo chmod +x *
cd $DIR

echo "Rewriting Terraform configuration files to a canonical format"
terraform fmt
