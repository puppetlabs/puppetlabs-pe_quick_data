plan pe_quick_data::data_collect (
  TargetSpec        $targets,
  Optional[String]  $output_dir = '/var/tmp',
  Optional[Boolean]  $enable_logs = false,
) {
    catch_errors() || {
      run_task('pe_quick_data::collect', $targets, output_dir => $output_dir, enable_logs => $enable_logs, '_catch_errors' => true)
      run_task('pe_quick_data::node_count', $targets, output_dir => $output_dir, '_catch_errors' => true)
      run_task('pe_quick_data::resources', $targets, output_dir => $output_dir)
      run_task('pe_quick_data::roles_and_profiles', $targets, output_dir => $output_dir)
      run_task('pe_quick_data::site_modules', $targets, output_dir => $output_dir)
      return run_task('pe_quick_data::zippedata', $targets, output_dir => $output_dir)
    }
  }
