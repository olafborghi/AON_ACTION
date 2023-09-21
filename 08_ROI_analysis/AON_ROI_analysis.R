# AON Study - ROI analysis ---------------------

## ROI Analysis Code
## Author: Olaf Borghi

# Session preparation ----------------------------------------------------------

## Packages

# install and load packages
packages <- c("rstudioapi", 
              "tidyverse", # collection of data science libraries
              "data.table", # data wrangling
              "afex", # analysis of factorial experiments / mixed models
              "qqconf", # needed for ggResidpanel
              "ggResidpanel", # assumption checks
              "xtable", # tables and corr analysis
              "ggsignif", # add significance to plot
              "gghalves", # plotting
              "ggpubr", # plotting
              "svglite", # save figs as svg
              "patchwork", # plot spacer
              "emmeans", # for post hoc tests
              "effsize", # additional effect sizes
              "flextable", # make nice tables
              "broom.mixed" # needed for flextables of mixed models
) 

installed_packages <- packages %in% rownames(installed.packages())
if (any(installed_packages == FALSE)) {
  install.packages(packages[!installed_packages])
}

invisible(lapply(packages, library, character.only = TRUE))

# packages from github
devtools::install_github("aljrico/gameofthrones")
devtools::install_github('jorvlan/raincloudplots')
library(gameofthrones)
library(raincloudplots)

# Set working directory to active path
setwd(dirname(getActiveDocumentContext()$path))
wd <- getwd()

# load flat violin plot script
source(paste0(wd, "/raincloud_functions.R"))

# sessionInfo for reproducability
sessionInfo()


# Data preparation --------------------------------------------------------

# Load and prepare data
data <- read.csv(paste0(getwd(), "/ROI_data.csv"), stringsAsFactors = TRUE) 
data <- as.data.table(data)

data$sex <- as.factor(data$sex)
data$observer_factor <- as.factor(data$observer_factor)

levels(data$sex)[levels(data$sex) == "0"] <- "woman"
levels(data$sex)[levels(data$sex) == "1"] <- "man"
levels(data$observer_factor)[levels(data$observer_factor) == "0"] <- "non-expert"
levels(data$observer_factor)[levels(data$observer_factor) == "1"] <- "expert"

head(data)

# First visual look at distribution of parameter estimates
ggplot(data, aes(activation)) +
  geom_histogram() +
  ggtitle("Distribution of parameter estimates")
print(shapiro.test(data$activation))


# Summary and descriptive statistics -------------------------------------------

# activation level means in different conditions
data %>%
  dplyr::group_by(action_factor, agent_factor, observer_factor) %>%
  dplyr::summarize(mean_activation = mean(activation))

data_unique <- unique(data, by = "participant_id")

# Sample size 
nrow(data_unique)

# participant descriptives
sbj <- data_unique[, .(meanAge = round(mean(age), 2),
                       sdAge = round(sd(age), 2),
                       medianAge = as.double(median(age)),
                       minAge = min(age),
                       maxAge = max(age),
                       n = length(participant_id),
                       women = sum(sex == "woman"),
                       men = sum(sex == "man"),
                       dog_experts = sum(observer_factor == "expert"),
                       non_experts = sum(observer_factor == "non-expert"))]
sbj



# Linear mixed models (LMMs) ----------------------------------------------

## Model 1

# set up sum contrast scheme
contrasts(data$action_factor) = c(-0.5, 0.5)
contrasts(data$agent_factor) = c(-0.5, 0.5)
contrasts(data$observer_factor) = c(-0.5, 0.5)
colnames(attr(data$action_factor, "contrasts")) = "t>i"
colnames(attr(data$agent_factor, "contrasts")) = "h>d"
colnames(attr(data$observer_factor, "contrasts")) = "e>ne"

# run main LMM across all regions
m1 <- lmer(activation ~ agent_factor * action_factor * observer_factor + (1 | participant_id) + (1 | region), data, REML=TRUE)
summary(m1)

# save m1
m1_table <- as_flextable(m1)
save_as_docx(m1_table, path=paste0(wd, "/m1_table.docx"))



# Post-hoc Tests ----------------------------------------------------------

options(max.print=999999) # to increase the number of parameters that are printed

## Agent * Action * Observer

# set up reference grid
em1 <- emmeans(m1, ~ agent_factor*action_factor*observer_factor)
em1

# test all pairwise comparisons
em1_pairs = pairs(em1, adjust = "fdr")
em1_pairs 

em1_pairs_df <- as.data.frame(em1_pairs)
write.csv(em1_pairs_df, paste0(wd, "/m1_pairwise_comparisons_FDR.csv"), 
          row.names = FALSE)

# effect sizes
m1_effsize <- eff_size(em1, sigma=sigma(m1), edf=55.7)
m1_effsize

em1_effsize_df <- as.data.frame(m1_effsize)
write.csv(em1_effsize_df, paste0(wd, "/m1_pairwise_effsize.csv"), 
          row.names = FALSE)

## Agent

# set up reference grid
em2 <- emmeans(m1, ~ agent_factor)
em2

# test all pairwise comparisons
em2_pairs = pairs(em2, adjust = "fdr")
em2_pairs 

## Action

# set up reference grid
em3 <- emmeans(m1, ~ action_factor)
em3

# test all pairwise comparisons
em3_pairs = pairs(em3, adjust = "fdr")
em3_pairs 

## Observer

# set up reference grid
em4 <- emmeans(m1, ~ observer_factor)
em4

# test all pairwise comparisons
em4_pairs = pairs(em4, adjust = "fdr")
em4_pairs 


# Follow-up investigation - Effects within action / feature processing regions -

# Contrast effects in each ROI type, FDR-corrected
model1.dfs <- list()
index = 1

# run a regression model for each ROI category & save the results as a df
for (type in unique(data$region_type)) {
  data_type = data %>% filter(region_type==type)
  model1 = lmer(activation ~ agent_factor * action_factor * observer_factor + (1|participant_id), 
               data=data_type, REML=TRUE)
  model1.df = data.frame(c('Intercept', 'Agent (human > dog)', 'Action (transitive > intransitive)',
                          'Observer (expert > non-expert)', 'Agent : Action', 'Agent : Observer',
                          'Action : Observer', 'Agent : Action : Observer'),
                        summary(model1)$coefficients[,'Estimate'],
                        summary(model1)$coefficients[,'Pr(>|t|)']) %>% 
    mutate(region_type=type)
  names(model1.df) = c('Regression Term', 'Beta', 'p.value', 'ROI')
  model1.df = model1.df[,c(4,1,2,3)] %>%
    mutate(Beta = round(Beta, 2))
  model1.dfs[[index]] <- model1.df
  index = index+1
}

stats1_df = do.call("rbind", model1.dfs)
# FDR correction
stats1_df = stats1_df %>%
  group_by('Regression Term') %>%
  mutate(p.value.FDR = p.adjust(p.value, method="fdr")) %>%
  mutate(p.value.FDR = ifelse((p.value.FDR>=0.001), as.character(round(p.value.FDR, 3)),
                              formatC(p.value.FDR, format = "e", digits = 2)))

stats1_df$p.value = NULL

write.table(stats1_df, file = "within_region-type_stats.csv", sep = ",", quote = FALSE, row.names = F)



# Follow-up investigation - Effects within ROIs ---------------------------

# Contrast effects in each ROI, FDR-corrected
model.dfs <- list()
index = 1

roi_list <- c("inferior_parietal_lobule",           
              "inferior_frontal_gyrus",             
              "premotor_cortex",                    
              "primary_motor_cortex",               
              "primary_somatosensory_cortex",       
              #"secondary_somatosensory_cortex", not included as rank deficiency breaks the code
              "lateral_occipital_cortex", 
              "fusiform_cortex",
              "area_V5",                           
              "posterior_superior_temporal_sulcus"
              )

# run a regression model for each ROI & save the results as a df
for (roi in roi_list) {
  data.roi = data %>% filter(region==roi)
  model = lmer(activation ~ agent_factor * action_factor * observer_factor + (1|participant_id), 
               data=data.roi, REML=TRUE)
  model.df = data.frame(c('Intercept', 'Agent (human > dog)', 'Action (transitive > intransitive)',
                           'Observer (expert > non-expert)', 'Agent : Action', 'Agent : Observer',
                           'Action : Observer', 'Agent : Action : Observer'),
                        summary(model)$coefficients[,'Estimate'],
                        summary(model)$coefficients[,'Pr(>|t|)']) %>% 
    mutate(region=roi)
  names(model.df) = c('Regression Term', 'Beta', 'p.value', 'ROI')
  model.df = model.df[,c(4,1,2,3)] %>%
    mutate(Beta = round(Beta, 2))
  model.dfs[[index]] <- model.df
  index = index+1
}

stats_df = do.call("rbind", model.dfs)
# FDR correction
stats_df = stats_df %>%
  group_by(`Regression Term`) %>%
  mutate(p.value.FDR = p.adjust(p.value, method="fdr")) %>%
  mutate(p.value.FDR = ifelse((p.value.FDR>=0.001), as.character(round(p.value.FDR, 3)),
                              formatC(p.value.FDR, format = "e", digits = 2)))

stats_df$p.value = NULL

write.table(stats_df, file = "within_ROI_stats.csv", sep = ",", quote = FALSE, row.names = F)


# quick check of the results of the code, using M1 as an example
data.M1 = subset(data, (region=="primary_motor_cortex"))
m.M1 = lmer(activation ~ agent_factor * action_factor * observer_factor + (1|participant_id), 
            data=data.M1, REML=TRUE)

summary(m.M1)

# Separate analysis for S2 due to rank deficiency
data.S2 = subset(data, (region=="secondary_somatosensory_cortex"))
m.S2 = lmer(activation ~ agent_factor * action_factor * observer_factor + (1|participant_id), 
                       data=data.S2, REML=TRUE)

summary(m.S2)


# Figures -----------------------------------------------------------------

data_fig <- data

data_fig <- data_fig %>%
  mutate(x_axis = case_when(
    action_factor == "transitive" & agent_factor == "human" & observer_factor == "non-expert" ~ 1,
    action_factor == "transitive" & agent_factor == "human" & observer_factor == "expert" ~ 2,
    action_factor == "intransitive" & agent_factor == "human" & observer_factor == "non-expert" ~ 3,
    action_factor == "intransitive" & agent_factor == "human" & observer_factor == "expert" ~ 4,
    action_factor == "transitive" & agent_factor == "dog" & observer_factor == "non-expert" ~ 5,
    action_factor == "transitive" & agent_factor == "dog" & observer_factor == "expert" ~ 6,
    action_factor == "intransitive" & agent_factor == "dog" & observer_factor == "non-expert" ~ 7,
    action_factor == "intransitive" & agent_factor == "dog" & observer_factor == "expert" ~ 8,
  ))

jit_distance = .08
jit_seed = 321
set.seed(jit_seed)
data_fig$jit <- jitter(data_fig$x_axis, amount = jit_distance)


#### 2x2x2 Plot Action (x-axis) * Agent (panel) * Observer (color) ####

colors = (c('dodgerblue', 'darkorange', 'dodgerblue', 'darkorange', 'dodgerblue', 'darkorange', 'dodgerblue', 'darkorange'))
fills = (c('dodgerblue', 'darkorange', 'dodgerblue', 'darkorange', 'dodgerblue', 'darkorange', 'dodgerblue', 'darkorange'))
line_color = 'gray'
line_alpha = .3
p_alpha = .3
size = 1.5
alpha = .6


fig <- ggplot(data = data_fig) +
  geom_point(data = data_fig %>% dplyr::filter(x_axis =="1"), 
             aes(x = jit, y = activation), color = colors[1], fill = fills[1], position = position_nudge(x = -.1), size = size, alpha = p_alpha) +
  geom_point(data = data_fig %>% dplyr::filter(x_axis =="2"), 
             aes(x = jit, y = activation), color = colors[2], fill = fills[2], position = position_nudge(x = -.5), size = size, alpha = p_alpha) +
  geom_point(data = data_fig %>% dplyr::filter(x_axis =="3"), 
             aes(x = jit, y = activation), color = colors[3], fill = fills[3], position = position_nudge(x = -.6), size = size, alpha = p_alpha) +
  geom_point(data = data_fig %>% dplyr::filter(x_axis =="4"), 
             aes(x = jit, y = activation), color = colors[4], fill = fills[4], position = position_nudge(x = -1), size = size, alpha = p_alpha) +
  geom_point(data = data_fig %>% dplyr::filter(x_axis =="5"), 
             aes(x = jit, y = activation), color = colors[5], fill = fills[5], position = position_nudge(x = .9), size = size, alpha = p_alpha) +
  geom_point(data = data_fig %>% dplyr::filter(x_axis =="6"), 
             aes(x = jit, y = activation), color = colors[6], fill = fills[6], position = position_nudge(x = .5), size = size, alpha = p_alpha) +
  geom_point(data = data_fig %>% dplyr::filter(x_axis =="7"), 
             aes(x = jit, y = activation), color = colors[7], fill = fills[7], position = position_nudge(x = .4), size = size, alpha = p_alpha) +
  geom_point(data = data_fig %>% dplyr::filter(x_axis =="8"), 
             aes(x = jit, y = activation), color = colors[8], fill = fills[8], position = position_nudge(x = .1), size = size, alpha = p_alpha) +
  geom_half_boxplot(data = data_fig %>% dplyr::filter(x_axis=="1"), 
                    aes(x=x_axis, y = activation), color = colors[1], fill = fills[1], position = position_nudge(x = -.3),
                    side = "l",outlier.shape = NA, center = TRUE, errorbar.draw = FALSE, width = .2, alpha = alpha) +
  geom_half_boxplot(data = data_fig %>% dplyr::filter(x_axis=="2"), 
                    aes(x=x_axis, y = activation), color = colors[2], fill = fills[2], position = position_nudge(x = -.7),
                    side = "l",outlier.shape = NA, center = TRUE, errorbar.draw = FALSE, width = .2, alpha = alpha) +
  geom_half_boxplot(data = data_fig %>% dplyr::filter(x_axis=="3"), 
                    aes(x=x_axis, y = activation), color = colors[3], fill = fills[3], position = position_nudge(x = -.3),
                    side = "r",outlier.shape = NA, center = TRUE, errorbar.draw = FALSE, width = .2, alpha = alpha) +
  geom_half_boxplot(data = data_fig %>% dplyr::filter(x_axis=="4"), 
                    aes(x=x_axis, y = activation), color = colors[4], fill = fills[4], position = position_nudge(x = -.7),
                    side = "r",outlier.shape = NA, center = TRUE, errorbar.draw = FALSE, width = .2, alpha = alpha) +
  geom_half_boxplot(data = data_fig %>% dplyr::filter(x_axis=="5"), 
                    aes(x=x_axis, y = activation), color = colors[5], fill = fills[5], position = position_nudge(x = .7),
                    side = "l",outlier.shape = NA, center = TRUE, errorbar.draw = FALSE, width = .2, alpha = alpha) +
  geom_half_boxplot(data = data_fig %>% dplyr::filter(x_axis=="6"), 
                    aes(x=x_axis, y = activation), color = colors[6], fill = fills[6], position = position_nudge(x = .3),
                    side = "l",outlier.shape = NA, center = TRUE, errorbar.draw = FALSE, width = .2, alpha = alpha) +
  geom_half_boxplot(data = data_fig %>% dplyr::filter(x_axis=="7"), 
                    aes(x=x_axis, y = activation), color = colors[7], fill = fills[7], position = position_nudge(x = .7),
                    side = "r",outlier.shape = NA, center = TRUE, errorbar.draw = FALSE, width = .2, alpha = alpha) +
  geom_half_boxplot(data = data_fig %>% dplyr::filter(x_axis=="8"), 
                    aes(x=x_axis, y = activation), color = colors[8], fill = fills[8], position = position_nudge(x = .3),
                    side = "r",outlier.shape = NA, center = TRUE, errorbar.draw = FALSE, width = .2, alpha = alpha) +
  geom_half_violin(data = data_fig %>% dplyr::filter(x_axis=="1"),
                   aes(x = x_axis, y = activation), color = colors[1], fill = fills[1], position = position_nudge(x = -.5),
                   side = "l", alpha = alpha) +
  geom_half_violin(data = data_fig %>% dplyr::filter(x_axis=="2"),
                   aes(x = x_axis, y = activation), color = colors[2], fill = fills[2], position = position_nudge(x = -1.5),
                   side = "l", alpha = alpha) +
  geom_half_violin(data = data_fig %>% dplyr::filter(x_axis=="3"),
                   aes(x = x_axis, y = activation), color = colors[3], fill = fills[3], position = position_nudge(x = .5),
                   side = "r", alpha = alpha) +
  geom_half_violin(data = data_fig %>% dplyr::filter(x_axis=="4"),
                   aes(x = x_axis, y = activation), color = colors[4], fill = fills[4], position = position_nudge(x = -.5),
                   side = "r", alpha = alpha) +
  geom_half_violin(data = data_fig %>% dplyr::filter(x_axis=="5"),
                   aes(x = x_axis, y = activation), color = colors[5], fill = fills[5], position = position_nudge(x = .5),
                   side = "l", alpha = alpha) +
  geom_half_violin(data = data_fig %>% dplyr::filter(x_axis=="6"),
                   aes(x = x_axis, y = activation), color = colors[6], fill = fills[6], position = position_nudge(x = -.5),
                   side = "l", alpha = alpha) +
  geom_half_violin(data = data_fig %>% dplyr::filter(x_axis=="7"),
                   aes(x = x_axis, y = activation), color = colors[7], fill = fills[7], position = position_nudge(x = 1.5),
                   side = "r", alpha = alpha) +
  geom_half_violin(data = data_fig %>% dplyr::filter(x_axis=="8"),
                   aes(x = x_axis, y = activation), color = colors[8], fill = fills[8], position = position_nudge(x = .5),
                   side = "r", alpha = alpha) +
  geom_segment(aes(x = 4.5, y = -2, xend = 4.5, yend = 6)) +
  scale_x_continuous(breaks=c(1,3,6,8), labels=c("transitive", "intransitive", "transitive", "intransitive"), limits=c(0, 10)) +
  ylab("BOLD Activation") + 
  theme_classic() +
  theme(axis.line = element_line(colour = 'black'),
        axis.title.x=element_blank(),
        axis.text.x=element_blank(),
        axis.title.y =element_text(size=12, face='bold', color="black"),
        strip.text.x = element_text(size = 12, face='bold', color="black"),
        legend.title= element_blank(),
        legend.position = "none") 
fig

ggsave(file="2x2x2_fig.svg", plot=fig, width=12, height=8)


#### Residual Plots ####

resid_panel(m1, plots = "all")
