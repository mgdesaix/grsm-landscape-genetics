get_snmf_plots <- function(project, choiceK){
  ce <- cross.entropy(project, K=choiceK)
  best_run <- which.min(ce)
  q_mat <- LEA::Q(project, K = choiceK, run = best_run)
  colnames(q_mat) <- paste0("K", 1:choiceK)
  q_df_arrange <- q_mat %>%
    cbind(SMsub) %>%
    pivot_longer(cols = 1:choiceK,
                 names_to = "K",
                 values_to = "Q") %>%
    group_by(SubjectID) %>%
    filter(Q == max(Q)) %>%
    rename("MaxK" = "K")


  p.barplot <- q_mat %>%
    cbind(SMsub) %>%
    pivot_longer(cols = 1:choiceK,
                 names_to = "K",
                 values_to = "Q") %>%
    left_join(q_df_arrange %>% select(SubjectID, MaxK), by = "SubjectID") %>%
    ggplot() +
    geom_col(aes(x = SubjectID, y = Q, fill = K)) +
    theme_minimal() +
    facet_grid(~MaxK, scales = "free")

  p.points <- q_df_arrange %>%
    rename("K" = "MaxK") %>%
    ggplot() +
    geom_point(aes(x = Long, y = Lat, color = K, alpha = Q),
               size = 4) +
    theme_minimal() +
    coord_equal() +
    guides(alpha = "none")

  out.list <- list("barplot" = p.barplot,
                   "points_map" = p.points)
}
