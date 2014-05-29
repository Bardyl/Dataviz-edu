// Generated by CoffeeScript 1.7.1
(function() {
  var active, countries, height, hover, inactive, map, polygon, separator, svg, svgHeight, svgWidth, tipSelectOne, tipSelectOther, tipSelectTwo, updateWindow, width;

  svg = d3.select('svg');

  polygon = svg.selectAll('polygon');

  height = window.innerHeight;

  width = window.innerWidth;

  svgHeight = svg.attr('height');

  svgWidth = svg.attr('width');

  countries = ['Espagne', 'France', 'Italie', 'Grèce', 'Allemagne', 'Belgique', 'Royaume-Uni', 'Irlande', 'Suède', 'Finlande', 'Norvège'];

  tipSelectOne = 'Sélectionnez un des pays en couleur afin de découvrir quel est son modèle éducatif !';

  tipSelectTwo = 'Sélectionnez un deuxième pays afin de comparer ses données au premier !';

  tipSelectOther = 'Cliquez sur un autre pays pour changer votre deuxième sélection ou réinitialisez pour recommencer.';

  separator = ' et ';

  active = '#f5b355';

  inactive = '#f8f8f8';

  hover = '#06A59B';

  updateWindow = function() {
    var temp;
    temp = (svgHeight - height) / 2 + 60;
    return svg.attr('viewBox', '0 ' + temp + ' ' + svgWidth + ' ' + svgHeight);
  };

  window.onresize = function() {
    return updateWindow();
  };

  updateWindow();

  map = {
    init: function() {
      polygon.each(function() {
        d3.select(this).classed('selected', false);
        d3.select(this).classed('second-selection', false);
        return d3.select(this).attr('fill', function() {
          if (countries.indexOf(d3.select(this).attr('data-pays')) > -1) {
            return active;
          } else {
            return inactive;
          }
        });
      });
      d3.selectAll('#infos h2').text('');
      d3.selectAll('#infos span').style('display', 'none');
      return d3.select('#tip').text(tipSelectOne);
    },
    changePointer: function() {
      return polygon.each(function() {
        if (d3.select(this).attr('fill') !== inactive) {
          return d3.select(this).style('cursor', 'pointer');
        }
      });
    },
    onMouseOver: function() {
      var country, el;
      map.changePointer();
      el = d3.select(this);
      country = el.attr('data-pays');

      /*
      		 * Some countries have more than one polygon. So we have to find all polygons with the same data-pays
      		 * Conditions needed : 
      		 * * Country clickable
      		 * * Data-pays is like country we are on hover (or the country has selected class)
       */
      return polygon.each(function() {
        if (el.attr('fill') !== inactive && d3.select(this).attr('data-pays') === country || d3.select(this).classed('selected') === true) {
          return d3.select(this).attr('fill', hover);
        }
      });
    },
    onMouseLeave: function() {
      return polygon.each(function() {
        if (d3.select(this).attr('fill') !== inactive && d3.select(this).classed('selected') === false) {
          return d3.select(this).attr('fill', active);
        }
      });
    },
    onClick: function() {
      var counter, country, counts, el, i, tempArray, textCountry, _i, _len;
      el = d3.select(this);
      country = el.attr('data-pays');
      counter = 0;
      tempArray = [];
      counts = [];
      polygon.each(function() {
        if (d3.select(this).classed('selected') === true) {
          return tempArray.push(d3.select(this).attr('data-pays'));
        }
      });
      for (_i = 0, _len = tempArray.length; _i < _len; _i++) {
        i = tempArray[_i];
        if (counts.indexOf(i) === -1) {
          counts.push(i);
        }
      }
      counter = counts.length;
      if (el.attr('fill') === hover) {
        switch (counter) {
          case 0:
            polygon.each(function() {
              if (d3.select(this).attr('data-pays') === el.attr('data-pays')) {
                return d3.select(this).classed('selected', true).attr('fill', hover);
              }
            });
            d3.select('.country').text(country);
            d3.select('#tip').text(tipSelectTwo);
            break;
          case 1:
            polygon.each(function() {
              if (d3.select(this).attr('data-pays') === el.attr('data-pays')) {
                return d3.select(this).classed('selected second-selection', true).attr('fill', hover);
              }
            });
            textCountry = d3.select('.country').text();
            d3.select('.country').text(textCountry + separator + el.attr('data-pays'));
            d3.select('.reset-map').style('display', 'inline-block');
            d3.select('#tip').text(tipSelectOther);
            break;
          case 2:
            polygon.each(function() {
              if (d3.select(this).classed('second-selection') === true) {
                d3.select(this).classed('selected second-selection', false);
                return d3.select(this).attr('fill', active);
              }
            });
            polygon.each(function() {
              if (d3.select(this).attr('data-pays') === el.attr('data-pays')) {
                return d3.select(this).classed('selected second-selection', true).attr('fill', hover);
              }
            });
            textCountry = d3.select('.country').text();
            textCountry = textCountry.split(' ');
            d3.select('.country').text(textCountry[0] + separator + el.attr('data-pays'));
        }
        return d3.select('.more-info').style('display', 'inline-block').attr('data-pays', country);
      }
    }
  };

  d3.select('.reset-map').on('click', map.init);

  polygon.on('mouseover', map.onMouseOver).on('mouseleave', map.onMouseLeave).on('click', map.onClick).each(function() {
    return d3.select(this).attr('fill', function() {
      if (countries.indexOf(d3.select(this).attr('data-pays')) > -1) {
        return active;
      } else {
        return inactive;
      }
    });
  });

}).call(this);
