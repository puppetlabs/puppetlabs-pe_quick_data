plan pe_quick_data::data_collect (
  TargetSpec        $targets,
  Optional[String]  $output_dir = '/var/tmp',
) {
    upload_file('pe_quick_data/common.sh', "${output_dir}/common.sh", $targets)
    run_task('pe_quick_data::collect', $targets, output_dir => $output_dir)
    run_task('pe_quick_data::node_count', $targets, output_dir => $output_dir)
    run_task('pe_quick_data::resources', $targets, output_dir => $output_dir)
    run_task('pe_quick_data::roles_and_profiles', $targets, output_dir => $output_dir)
    run_task('pe_quick_data::zippedata', $targets, output_dir => $output_dir)
  }
