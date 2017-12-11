args = commandArgs(trailingOnly=TRUE)

if(length(args)!=2) {
	stop("At least two arguments must be supplied (working directory and input file)", call.=FALSE)
} else {
	setwd(args[1])
	data <- read.csv(args[2], header=TRUE, sep=',')
}

require("ggplot2")

data[c('request', 'answer')] <- sapply(data[c('request', 'answer')], function(x) strptime(x, "%Y-%m-%dT%H:%M:%S"))
data['result'] <- sapply(data['result'], function(x) factor(x))
data['simulation_time'] <- sapply(data['simulation_time'], function(x) as.numeric(x))

convert_time <- function(x) {
	minutes = x / 60
	hours = minutes / 60
	minutes = minutes %% 60
	seconds = x %% 60
	sprintf("%1.0fh %1.0fmin %1.0fs", hours, minutes, seconds)
}

##############################################################################

result <- data$result
rate <- as.data.frame(table(result))

Estado <- c("Erro", "Sucesso")
theme_set(theme_gray(base_size = 18))
png('rate.png')
ggplot(rate, aes(result, Freq, fill=Estado)) + geom_bar(stat="identity", width=.6) +
xlab("Estado da resposta da requisição") + ylab("Requisições") +
theme(axis.text.x=element_blank(), axis.ticks.x=element_blank())
dev.off()

##############################################################################

request <- data$request

sum <- function(x) {
	hours = as.numeric(format(x, "%H"))
	minutes = as.numeric(format(x, "%M"))

	hours = ifelse(hours<=0,24,hours)

	hours*60 + minutes
}

data['request_sum'] <- sapply(data['request'], sum)

initial <- data$request_sum[1] - 1
data['request_sum'] <- sapply(data['request_sum'], function(x) x - initial)

theme_set(theme_gray(base_size = 18))
png('load.png')
ggplot(data, aes(request_sum)) + geom_histogram(col='white') +
ylab("Requisições") + xlab("Tempo (min)") +
theme(legend.position="none")
dev.off()

##############################################################################

rate_data <- split(data, data$result)
success <- rate_data[['success']]
error <- rate_data[['error']]

success$response_time <- success$response_time_mili - success$request_time_mili
success['request_sum'] <- sapply(success['request'], sum )
success['request_time'] <- sapply(success['request'], function(x) format(x, "%H:%M"))

success['simulation_response'] <- success['simulation_time'] + success['response_time']
success['simulation_response'] <- sapply(success['simulation_response'], function(x) as.numeric(x))

theme_set(theme_gray(base_size = 18))
png('response_time_boxplot.png')
boxplot(success$response_time, outline=FALSE)
dev.off()

rt_resume <- aggregate(success$response_time~success$request_sum, success, mean)

time <- unlist(rt_resume[1])
mean <- unlist(rt_resume[2])
plot <- data.frame(time, mean)

initial <- plot$time[1] - 1
plot['time'] <- sapply(plot['time'], function(x) x - initial)

theme_set(theme_gray(base_size = 18))
png('response_time.png')
ggplot(plot, aes(time, mean)) + geom_bar(stat="identity") +
#scale_x_continuous(breaks=seq(0, 35, 5), lim=c(0,32)) +
xlab("Tempo (min)") + ylab("Média do tempo de resposta (ms)")
dev.off()

print("DONE")

##############################################################################

success['answer_sum'] <- sapply(success['answer'], sum )

initial <- success$answer_sum[1] - 1
success['answer_sum'] <- sapply(success['answer_sum'], function(x) x - initial)

theme_set(theme_gray(base_size = 18))
png('throughput.png')
ggplot(success, aes(answer_sum)) + geom_histogram(col='white') +
#scale_x_continuous(breaks=seq(0, 35, 5), lim=c(0,33)) +
ylab("Respostas com sucesso") + xlab("Tempo (min)") +
theme(legend.position="none")
dev.off()

print("DONE 2")
