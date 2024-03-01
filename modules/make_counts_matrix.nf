/**
 * Process to make a counts matrix from many individual counts files
 *
 * make_counts_matrix script is packaged in the utia-gc/rnaseq bin
 *
 * @input counts the collection of individual counts files.
 * @input prefix the prefix value for naming the output file
 *
 * @output countsMatrix the combined counts matrix
 * @output featuresMetadata the metadata for the features from the counts data
 */
process make_counts_matrix {
    label 'pandas'

    label 'def_cpu'
    label 'def_mem'
    label 'def_time'

    publishDir(
        path:    "${params.publishDirData}/counts",
        mode:    "${params.publishMode}",
        pattern: '*.csv'
    )

    input:
        path counts
        val prefix

    output:
        path "${prefix}_counts.csv",                  emit: countsMatrix
        path "${prefix}_counts_feature_metadata.csv", emit: featuresMetadata

    script:
        """
        make_counts_matrix \\
            --prefix ${prefix}_counts \\
            ${counts}
        """
}
