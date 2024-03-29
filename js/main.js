// Generated by CoffeeScript 1.7.1
(function() {
  var active, countries, datas, filterList, filters, graph, height, hover, inactive, map, modelEducatif, polygon, popupAtStart, separator, svg, svgHeight, svgWidth, tipSelectOne, tipSelectOther, tipSelectTwo, updateWindow, width;

  svg = d3.select('#leftContent svg');

  polygon = svg.selectAll('polygon');

  filterList = d3.select('#displayData nav');

  height = window.innerHeight;

  width = window.innerWidth;

  svgHeight = svg.attr('height');

  svgWidth = svg.attr('width');

  countries = ['Espagne', 'France', 'Italie', 'Grèce', 'Allemagne', 'Belgique', 'Royaume-Uni', 'Finlande', 'Norvège', 'Luxembourg'];

  tipSelectOne = 'Sélectionnez un des pays en couleur afin de découvrir quel est son modèle éducatif !';

  tipSelectTwo = 'Sélectionnez un deuxième pays afin de comparer ses données au premier !';

  tipSelectOther = 'Cliquez sur un autre pays pour changer votre deuxième sélection ou réinitialisez pour recommencer.';

  separator = ' et ';

  modelEducatif = 'Le modèle éducatif ';

  active = '#f5b355';

  inactive = '#f8f8f8';

  hover = '#06A59B';

  popupAtStart = true;

  updateWindow = function() {
    var temp;
    temp = (svgHeight - height) / 2 + 60;
    return svg.attr('viewBox', '0 ' + temp + ' ' + svgWidth + ' ' + svgHeight);
  };

  window.onresize = function() {
    return updateWindow();
  };

  updateWindow();

  popupAtStart = localStorage.getItem('blurInfos');

  if (popupAtStart === null) {
    d3.select('#blur').classed('closed', false);
  }

  d3.select('#blur button').on('click', function() {
    d3.select('#blur').classed('closed', true);
    return localStorage.setItem('blurInfos', 'bonjour');
  });

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
      if (el.attr('fill') === hover && el.classed('selected') === false) {
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

  graph = {
    init: function(filter) {
      d3.json('data/filters.json', function(root) {
        if (filter === 'noFilter') {
          return d3.select('#graph-description').html('');
        } else {
          return d3.select('#graph-description').html(root[filter].html);
        }
      });
      d3.selectAll('#datas > div').classed('active', false);
      d3.select('#' + filter).classed('active', true);
      return graph.createGraph(filter);
    },
    createGraph: function(filter) {
      var country, cycles, el, matieres, ratios, salaires, scores;
      el = d3.select('#' + filter);
      country = d3.select('#displayData').attr('data-pays');
      switch (filter) {
        case 'coutEtudiant':
          cycles = ['primaire', 'college', 'lycee'];
          return d3.json('data/countries/' + country + '.json', function(data) {
            var key, numbers, _i, _len, _results;
            numbers = data[filter];
            _results = [];
            for (_i = 0, _len = cycles.length; _i < _len; _i++) {
              key = cycles[_i];
              _results.push(d3.select('#coutEtudiant .' + key + ' span').text(numbers[key]['cout']));
            }
            return _results;
          });
        case 'encadrement':
          cycles = ['primaire', 'college', 'lycee'];
          return d3.json('data/countries/' + country + '.json', function(data) {
            var key, _i, _len, _results;
            data = data[filter];
            _results = [];
            for (_i = 0, _len = cycles.length; _i < _len; _i++) {
              key = cycles[_i];
              d3.select('#encadrement .' + key + ' .elevesParClass .value').text(data[key]['elevesParClass']);
              _results.push(d3.select('#encadrement .' + key + ' .elevesParEnseignant .value').text(data[key]['elevesParEnseignant']));
            }
            return _results;
          });
        case 'rythme':
          d3.selectAll('#rythme .graph-bar .totalStudy').style('width', '0%');
          d3.selectAll('#rythme .graph-bar .totalVacs').style('width', '0%');
          cycles = ['primaire', 'college', 'lycee'];
          return d3.json('data/countries/' + country + '.json', function(data) {
            var key, percentageVacs, percentageWork, _i, _len, _results;
            data = data[filter];
            _results = [];
            for (_i = 0, _len = cycles.length; _i < _len; _i++) {
              key = cycles[_i];
              percentageWork = (data[key]['daysByYear'] / data[key]['daysByWeek']) * 100 / 52;
              percentageVacs = data[key]['totalVacs'] * 100 / 52;
              d3.select('#rythme .' + key + ' .graph-bar .totalStudy').transition().duration(1500).style('width', (percentageWork - 2) + '%');
              d3.select('#rythme .' + key + ' .graph-bar .totalVacs').transition().duration(1500).style('width', (percentageVacs - 2) + '%');
              d3.select('#rythme .' + key + ' .graph-data .totalStudy').attr('style', 'width:' + (percentageWork - 2) + '%');
              d3.select('#rythme .' + key + ' .graph-data .totalVacs').attr('style', 'width:' + (percentageVacs - 2) + '%');
              d3.select('#rythme .' + key + ' .graph-data .totalStudy > span:first-child span').text(data[key]['daysByYear']);
              d3.select('#rythme .' + key + ' .graph-data .totalStudy > span:last-child span').text(data[key]['daysByWeek']);
              d3.select('#rythme .' + key + ' .graph-data .totalVacs > span:first-child span').text(data[key]['summerVacs']);
              _results.push(d3.select('#rythme .' + key + ' .graph-data .totalVacs > span:last-child span').text(data[key]['totalVacs']));
            }
            return _results;
          });
        case 'salaire':
          d3.selectAll('#salaire .graph-start').style('width', '0%');
          d3.selectAll('#salaire .graph-end').style('width', '0%');
          salaires = [];
          cycles = ['primaire', 'college', 'lycee'];
          return d3.json('data/countries/' + country + '.json', function(data) {
            var key, percentage, salaireEnd, salaireStart, _i, _len, _results;
            salaires = data[filter];
            _results = [];
            for (_i = 0, _len = cycles.length; _i < _len; _i++) {
              key = cycles[_i];
              salaireStart = salaires[key]['start'];
              salaireEnd = salaires[key]['end'];
              d3.select('#salaire .' + key + ' .start').text(salaireStart);
              d3.select('#salaire .' + key + ' .preetyName').text(salaires[key]['preetyName']);
              d3.select('#salaire .' + key + ' .end').text(salaireEnd);
              percentage = salaireStart * 100 / salaireEnd;
              d3.select('#salaire .' + key + ' .graph-start').transition().duration(1500).style('width', percentage + '%');
              _results.push(d3.select('#salaire .' + key + ' .graph-end').transition().duration(1500).style('width', '100%'));
            }
            return _results;
          });
        case 'cycle':
          d3.select('#cycle .graph-bar').style('width', '0%');
          cycles = ['primaire', 'college', 'lycee'];
          return d3.json('data/countries/' + country + '.json', function(data) {
            var heuresParAn, key, nombreAnneesCycles, nombreAnneesOblig, nombreTotalAnnees, percentageCycleWidth, percentageWidth, sum, _i, _j, _len, _len1, _results;
            data = data[filter];
            nombreTotalAnnees = [];
            for (_i = 0, _len = cycles.length; _i < _len; _i++) {
              key = cycles[_i];
              nombreTotalAnnees.push(data[key]['number']);
            }
            sum = nombreTotalAnnees.reduce(function(pv, cv) {
              return pv + cv;
            });
            _results = [];
            for (_j = 0, _len1 = cycles.length; _j < _len1; _j++) {
              key = cycles[_j];
              nombreAnneesCycles = data[key]['number'];
              nombreAnneesOblig = data[key]['numberOblig'];
              heuresParAn = data[key]['hours'];
              d3.select('#cycle .graph-bar').transition().duration(2000).style('width', '100%');
              percentageWidth = nombreAnneesCycles * 100 / sum;
              d3.selectAll('#cycle .' + key).attr('style', 'width:' + (percentageWidth - 1) + '%');
              percentageCycleWidth = nombreAnneesOblig * 100 / nombreAnneesCycles;
              d3.selectAll('#cycle .' + key + ' .nombreAnneesOblig').attr('style', 'width:' + percentageCycleWidth + '%');
              d3.selectAll('#cycle .' + key + ' .nombreAnneesNonOblig').attr('style', 'margin-left:' + percentageCycleWidth + '%');
              d3.select('#cycle .numbers .' + key + ' .nombreAnneesOblig').transition().text(nombreAnneesOblig);
              if (nombreAnneesCycles - nombreAnneesOblig !== 0) {
                d3.select('#cycle .numbers .' + key + ' .nombreAnneesNonOblig').text(nombreAnneesCycles - nombreAnneesOblig);
              }
              _results.push(d3.select('#cycle .cycle .' + key + ' span:last-child').text(heuresParAn + 'h par an'));
            }
            return _results;
          });
        case 'test':
          scores = [];
          matieres = ['maths', 'ecrit', 'science'];
          d3.selectAll('#test .graph-bar').style('height', '0%');
          return d3.json('data/countries/' + country + '.json', function(data) {
            var key, percentage, score, _i, _len, _results;
            scores = data[filter];
            _results = [];
            for (_i = 0, _len = matieres.length; _i < _len; _i++) {
              key = matieres[_i];
              score = scores[key]['score'];
              d3.select('#test .' + key + ' .preetyName').text(scores[key]['preetyName']);
              d3.select('#test .' + key + ' .score').text(score);
              percentage = score * 100 / 1000;
              _results.push(d3.select('#test .' + key + ' .graph-bar').transition().duration(1000).style('height', percentage + '%'));
            }
            return _results;
          });
        case 'ratioHF':
          d3.selectAll('#ratioHF div').remove();
          ratios = [];
          cycles = ['primaire', 'college', 'lycee'];
          return d3.json('data/countries/' + country + '.json', function(data) {
            var arc, arcs, key, man, pie, radius, ratio, vis, women, _i, _len, _results;
            ratios = data[filter];
            _results = [];
            for (_i = 0, _len = cycles.length; _i < _len; _i++) {
              key = cycles[_i];
              man = ratios[key]['man'];
              women = ratios[key]['women'];
              ratio = [
                {
                  "label": "Homme",
                  "value": man,
                  "color": "#f6c37a",
                  "textColor": '#834d00'
                }, {
                  "label": "Femme",
                  "value": women,
                  "color": "#45b4a4",
                  "textColor": '#005046'
                }
              ];
              width = 150;
              height = 150;
              radius = 75;
              vis = d3.select('#ratioHF').append('div').classed(key, true).append('svg:svg').data([ratio]).attr('width', width).attr('height', height).append('svg:g').attr('transform', 'translate(' + radius + ',' + radius + ')');
              d3.select('#ratioHF > div:last-child').append('span').classed('preetyName', true).text(function(d, i) {
                return ratios[key].preetyName;
              });
              arc = d3.svg.arc().outerRadius(radius);
              pie = d3.layout.pie().value(function(d) {
                return d.value;
              });
              arcs = vis.selectAll('g.slice').data(pie).enter().append('svg:g').attr('class', 'slice');
              arcs.append('svg:path').attr('fill', function(d, i) {
                return ratio[i].color;
              }).attr('d', arc);
              _results.push(arcs.append('svg:text').attr('transform', function(d) {
                d.innerRadius = 0;
                d.outerRadius = radius;
                return "translate(" + arc.centroid(d) + ")";
              }).attr('text-anchor', "middle").attr('fill', function(d, i) {
                return ratio[i].textColor;
              }).attr('style', 'font-size:.7em').text(function(d, i) {
                return ratio[i].value + '%';
              }));
            }
            return _results;
          });
        case 'sport':
          d3.selectAll('#sport div').remove();
          ratios = [];
          cycles = ['primaire', 'college', 'lycee'];
          return d3.json('data/countries/' + country + '.json', function(data) {
            var arc, arcs, key, minHoursByYear, minPercentage, pie, radius, ratio, vis, _i, _len, _results;
            ratios = data[filter];
            _results = [];
            for (_i = 0, _len = cycles.length; _i < _len; _i++) {
              key = cycles[_i];
              minPercentage = ratios[key]['minPercentage'];
              minHoursByYear = ratios[key]['minHoursByYear'];
              ratio = [
                {
                  "label": "",
                  "value": minPercentage,
                  "color": "#f6c37a",
                  "textColor": '#834d00'
                }, {
                  "label": "",
                  "value": 100 - minPercentage,
                  "color": "#45b4a4",
                  "textColor": '#005046'
                }
              ];
              width = 150;
              height = 150;
              radius = 75;
              vis = d3.select('#sport').append('div').classed(key, true).append('svg:svg').data([ratio]).attr('width', width).attr('height', height).append('svg:g').attr('transform', 'translate(' + radius + ',' + radius + ')');
              d3.select('#sport > div:last-child').append('span').classed('info', true).text(function(d, i) {
                return '(Soit ' + ratios[key].minHoursByYear + ' heures par an)';
              });
              d3.select('#sport > div:last-child').append('span').classed('preetyName', true).text(function(d, i) {
                return ratios[key].preetyName;
              });
              arc = d3.svg.arc().outerRadius(radius);
              pie = d3.layout.pie().value(function(d) {
                return d.value;
              });
              arcs = vis.selectAll('g.slice').data(pie).enter().append('svg:g').attr('class', 'slice');
              arcs.append('svg:path').attr('fill', function(d, i) {
                return ratio[i].color;
              }).attr('d', arc);
              _results.push(arcs.append('svg:text').attr('transform', function(d) {
                d.innerRadius = 0;
                d.outerRadius = radius;
                return "translate(" + arc.centroid(d) + ")";
              }).attr('text-anchor', "middle").attr('fill', function(d, i) {
                return ratio[i].textColor;
              }).attr('style', 'font-size:.7em').text(function(d, i) {
                return ratio[i].value + '%';
              }));
            }
            return _results;
          });
      }
    }
  };

  filters = {
    onMouseOver: function() {
      var info;
      info = d3.select(this).attr('data-filter');
      return d3.json('data/filters.json', function(root) {
        return d3.select('#active-filter').text(root[info].short);
      });
    },
    onMouseLeave: function() {
      return filterList.selectAll('div').each(function() {
        var info;
        if (d3.select(this).classed('active') === true) {
          info = d3.select(this).attr('data-filter');
          return d3.json('data/filters.json', function(root) {
            return d3.select('#active-filter').text(root[info].short);
          });
        }
      });
    },
    onClick: function() {
      var el, info;
      el = d3.select(this);
      info = d3.select(this).attr('data-filter');
      filterList.selectAll('div').classed('active', false);
      el.classed('active', true);
      d3.json('data/filters.json', function(root) {
        return d3.select('#active-filter').text(root[info].short);
      });
      return graph.init(info);
    }
  };

  datas = {
    init: function() {
      var el;
      d3.select('#leftContent').classed('extended', true);
      d3.select('#displayData').classed('dataPanelOpened', true);
      d3.select('#filters').classed('closed', true);
      map.init();
      el = d3.select(this);
      d3.select('#displayData').attr('data-pays', el.attr('data-pays'));
      return d3.json('data/countries/' + el.attr('data-pays') + '.json', function(root) {
        return d3.select('#datas h2').text(modelEducatif + root.preposition + el.attr('data-pays'));
      });
    },
    close: function() {
      d3.select('#leftContent').classed('extended', false);
      d3.select('#displayData').classed('dataPanelOpened', false);
      return d3.select('#filters').classed('closed', false);
    }
  };

  d3.select('.reset-map').on('click', map.init);

  polygon.on('mouseover', map.onMouseOver).on('mouseleave', map.onMouseLeave).on('click', map.onClick).each(function(d) {
    return d3.select(this).attr('fill', function() {
      if (countries.indexOf(d3.select(this).attr('data-pays')) > -1) {
        return active;
      } else {
        return inactive;
      }
    });
  });

  filterList.on('mouseleave', filters.onMouseLeave).selectAll('div').on('mouseover', filters.onMouseOver).on('click', filters.onClick);

  d3.select('.more-info').on('click', datas.init);

  d3.select('#closeDataView').on('click', datas.close);

}).call(this);
