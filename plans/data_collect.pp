plan pe_quick_data::data_collect (
  TargetSpec        $targets,
  Optional[String]  $output_dir = '/var/tmp',
  Optional[Boolean] $enable_logs = false,
  Optional[Boolean] $download = false,
) {
    catch_errors() || {
      run_task('pe_quick_data::collect', $targets, output_dir => $output_dir, enable_logs => $enable_logs, '_catch_errors' => true)
      run_task('pe_quick_data::node_count', $targets, output_dir => $output_dir, '_catch_errors' => true)
      run_task('pe_quick_data::resources', $targets, output_dir => $output_dir)
      run_task('pe_quick_data::site_modules', $targets, output_dir => $output_dir)
      $zipresult = run_task('pe_quick_data::zippedata', $targets, output_dir => $output_dir, download => $download)

      $zipresult.each |$result| {
        if $download {
            $rmessage = $result.message
            $downresults = download_file($rmessage, 'pe_quick_data', $targets, '_catch_errors' => true)
            # out::message($downresults)
            $downresults.each |$dresult| {
              if $dresult.ok {
                $dmessage = $dresult.message
                out::message($dmessage)
              } else {
                  out::message(" { status: ${dresult.status}, result: ${dresult.error} } ")
              }
            }
        } else {
          $rvalue = $result.value
          out::message($rvalue)
        }
      }
  }
}
