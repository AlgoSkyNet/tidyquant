#' Plot Financial Charts in ggplot2
#'
#' Financial charts provide visual cues to open, high, low, and close prices.
#' Use \code{\link{coord_x_date}} to zoom into specific plot regions.
#' The following financial chart geoms are available:
#' \itemize{
#'    \item \strong{\href{http://www.investopedia.com/terms/b/barchart.asp}{Bar Chart}}
#'    \item \strong{\href{http://www.investopedia.com/terms/c/candlestick.asp}{Candlestick Chart}}
#' }
#'
#' @inheritParams geom_ma
#' @inheritParams ggplot2::geom_linerange
#' @param color_up,color_down Select colors to be applied based on price movement
#' from open to close. If close >= open, \code{color_up} is used. Otherwise,
#' \code{color_down} is used. The default is "darkblue" and "red", respectively.
#' @param fill_up,fill_down Select fills to be applied based on price movement
#' from open to close. If close >= open, \code{fill_up} is used. Otherwise,
#' \code{fill_down} is used. The default is "darkblue" and "red", respectively.
#' Only affects \code{geom_candlestick}.
#'
#' @section Aesthetics:
#' The following aesthetics are understood (required are in bold):
#' \itemize{
#'    \item \strong{\code{x}}, Typically a date
#'    \item \strong{\code{open}}, Required to be the open price
#'    \item \strong{\code{high}}, Required to be the high price
#'    \item \strong{\code{low}}, Required to be the low price
#'    \item \strong{\code{close}}, Required to be the close price
#'    \item \code{alpha}
#'    \item \code{group}
#'    \item \code{linetype}
#'    \item \code{size}
#' }
#'
#' @seealso See individual modeling functions for underlying parameters:
#' \itemize{
#'    \item \code{\link{geom_ma}} for adding moving averages to ggplots
#'    \item \code{\link{geom_bbands}} for adding Bollinger Bands to ggplots
#'    \item \code{\link{coord_x_date}} for zooming into specific regions of a plot
#' }
#'
#' @name geom_chart
#'
#' @export
#'
#' @examples
#' # Load libraries
#' library(tidyquant)
#'
#' AAPL <- tq_get("AAPL")
#'
#' # Bar Chart
#' AAPL %>%
#'     ggplot(aes(x = date, y = close)) +
#'     geom_barchart(aes(open = open, high = high, low = low, close = close)) +
#'     geom_ma(color = "darkgreen") +
#'     coord_x_date(xlim = c(today() - weeks(6), today()),
#'                  ylim = c(100, 130))
#'
#' # Candlestick Chart
#' AAPL %>%
#'     ggplot(aes(x = date, y = close)) +
#'     geom_candlestick(aes(open = open, high = high, low = low, close = close)) +
#'     geom_ma(color = "darkgreen") +
#'     coord_x_date(xlim = c(today() - weeks(6), today()),
#'                  ylim = c(100, 130))

# Bar Chart -----

#' @rdname geom_chart
#' @export
geom_barchart <- function(mapping = NULL, data = NULL, stat = "identity",
                             position = "identity", na.rm = TRUE, show.legend = NA,
                             inherit.aes = TRUE,
                             color_up = "darkblue", color_down = "red",
                             fill_up = "darkblue", fill_down = "red",
                             ...) {



    linerange <- ggplot2::layer(
        stat = StatLinerangeBC, geom = GeomLinerangeBC, data = data, mapping = mapping,
        position = position, show.legend = show.legend, inherit.aes = inherit.aes,
        params = list(na.rm = na.rm, fill_up = fill_up, fill_down = fill_down,
                      color_up = color_up, color_down = color_down, ...)
    )

    segment_left <- ggplot2::layer(
        stat = StatSegmentLeftBC, geom = GeomSegmentBC, data = data, mapping = mapping,
        position = position, show.legend = show.legend, inherit.aes = inherit.aes,
        params = list(na.rm = na.rm, fill_up = fill_up, fill_down = fill_down,
                      color_up = color_up, color_down = color_down, ...)
    )

    segment_right <- ggplot2::layer(
        stat = StatSegmentRightBC, geom = GeomSegmentBC, data = data, mapping = mapping,
        position = position, show.legend = show.legend, inherit.aes = inherit.aes,
        params = list(na.rm = na.rm, fill_up = fill_up, fill_down = fill_down,
                      color_up = color_up, color_down = color_down, ...)
    )

    list(linerange, segment_left, segment_right)
}

StatLinerangeBC <- ggplot2::ggproto("StatLinerangeBC", Stat,
                                    required_aes = c("x", "open", "high", "low", "close"),

                                    compute_group = function(data, scales, params,
                                                             fill_up, fill_down,
                                                             color_up, color_down) {

                                        data <-  data %>%
                                            dplyr::mutate(color = ifelse(open < close, color_up, color_down))

                                        tibble::tibble(x = data$x,
                                                       ymin = data$low,
                                                       ymax = data$high,
                                                       colour = data$color)
                                    }
)

StatSegmentLeftBC <- ggplot2::ggproto("StatSegmentLeftBC", Stat,
                                    required_aes = c("x", "open", "high", "low", "close"),

                                    compute_group = function(data, scales, params,
                                                             fill_up, fill_down,
                                                             color_up, color_down) {

                                        data <-  data %>%
                                            dplyr::mutate(color = ifelse(open < close, color_up, color_down))

                                        tibble::tibble(x    = data$x,
                                                       xend = data$x - 0.5,
                                                       y    = data$open,
                                                       yend = data$open,
                                                       colour = data$color)
                                    }
)


StatSegmentRightBC <- ggplot2::ggproto("StatSegmentRightBC", Stat,
                                      required_aes = c("x", "open", "high", "low", "close"),

                                      compute_group = function(data, scales, params,
                                                               fill_up, fill_down,
                                                               color_up, color_down) {

                                          data <-  data %>%
                                              dplyr::mutate(color = ifelse(open < close, color_up, color_down))

                                          tibble::tibble(x    = data$x,
                                                         xend = data$x + 0.5,
                                                         y    = data$close,
                                                         yend = data$close,
                                                         colour = data$color)
                                      }
)

GeomLinerangeBC <- ggproto("GeomLinerangeBC", GeomLinerange,
                           default_aes = aes(size = 0.5,
                                             linetype = 1,
                                             alpha = NA)
)

GeomSegmentBC <- ggproto("GeomSegmentBC", GeomSegment,
                       default_aes = aes(size = 0.5,
                                         linetype = 1,
                                         alpha = NA)
)


# Candlestick Chart -----

#' @rdname geom_chart
#' @export
geom_candlestick <- function(mapping = NULL, data = NULL, stat = "identity",
                                position = "identity", na.rm = TRUE, show.legend = NA,
                                inherit.aes = TRUE,
                                color_up = "darkblue", color_down = "red",
                                fill_up = "darkblue", fill_down = "red",
                                ...) {

    linerange <- ggplot2::layer(
        stat = StatLinerangeBC, geom = GeomLinerangeBC, data = data, mapping = mapping,
        position = position, show.legend = show.legend, inherit.aes = inherit.aes,
        params = list(na.rm = na.rm, fill_up = fill_up, fill_down = fill_down,
                      color_up = color_up, color_down = color_down, ...)
    )

    rect <- ggplot2::layer(
        stat = StatRectCS, geom = GeomRectCS, data = data, mapping = mapping,
        position = position, show.legend = show.legend, inherit.aes = inherit.aes,
        params = list(na.rm = na.rm, fill_up = fill_up, fill_down = fill_down,
                      color_up = color_up, color_down = color_down, ...)
    )



    list(linerange, rect)
}

StatRectCS <- ggplot2::ggproto("StatRectCS", Stat,
                                required_aes = c("x", "open", "high", "low", "close"),

                                compute_group = function(data, scales, params,
                                                         fill_up, fill_down,
                                                         color_up, color_down) {

                                    data <-  data %>%
                                        dplyr::mutate(fill = ifelse(open < close, fill_up, fill_down),
                                                      ymin = ifelse(open < close, open, close),
                                                      ymax = ifelse(open < close, close, open))

                                    tibble::tibble(xmin = data$x - 0.45,
                                                   xmax = data$x + 0.45,
                                                   ymin = data$ymin,
                                                   ymax = data$ymax,
                                                   fill = data$fill)
                                }
)





GeomRectCS <- ggproto("GeomRectCS", GeomRect,
                      default_aes = aes(colour = NA,
                                        size = 0.5,
                                        linetype = 1,
                                        alpha = NA)
)


