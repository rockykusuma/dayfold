import { CalendarDays, ChevronLeft, FileText, Settings, ChevronRight, Inbox, Library, NotebookText, Search, Star, Users } from 'lucide-react'
import { useLayoutEffect, useRef, useState, type ReactNode } from 'react'
import { Badge, Bar, Button, Check, Collapse, Phone, Roll, Row, Stage, Text, Window, type Act } from './kit'
import './dayfold.css'

// Dayfold's hero: open tasks carry forward on their own. Tick one task done,
// step to tomorrow: what was finished stays behind, what's open is already on
// tomorrow's page, a day older. Back to Today and untick, so the loop ends
// where it began.

type Day = 'today' | 'tomorrow'
type S = { done: boolean; day: Day }

const initial: S = { done: false, day: 'today' }
const POSTER: S = { done: true, day: 'tomorrow' }

const REST = { wide: { x: 600, y: 330 }, compact: { x: 290, y: 380 } }

async function script(a: Act<S>) {
  await a.wait(900)

  // 1. Tick a task done
  a.mark('tick')
  await a.move({ at: 'check-review', x: 0.8, y: 0.85 })
  await a.wait(200)
  await a.click()
  await a.set({ done: true })
  await a.wait(1000)

  // 2. Step to tomorrow: open tasks are already there, a day older
  a.mark('tomorrow')
  await a.move({ at: 'next', x: 0.78, y: 0.78 })
  await a.wait(200)
  await a.click()
  await a.set({ day: 'tomorrow' })
  await a.move('rest')
  await a.wait(2600)

  // 3. Back to today, and untick: the page is as it began
  a.mark('back')
  await a.move({ at: 'today', x: 0.8, y: 0.6 })
  await a.wait(200)
  await a.click()
  await a.set({ day: 'today' })
  await a.wait(900)
  await a.move({ at: 'check-review', x: 0.8, y: 0.85 })
  await a.wait(200)
  await a.click()
  await a.set({ done: false })
  await a.wait(500)
  await a.move('rest')
  await a.wait(900)
}

function Age({ days }: { days: number }) {
  return (
    <Badge tone={days >= 3 ? 'warning' : 'neutral'} className="dh-age">
      <Roll>{`${days}d`}</Roll>
    </Badge>
  )
}

function Task({ title, meta, lead, done, target, pad = 8 }: { title: ReactNode; meta: ReactNode; lead?: ReactNode; done?: boolean; target?: string; pad?: number }) {
  return (
    <Row
      className="dh-task"
      data-done={done || undefined}
      lead={lead ?? <Check on={!!done} size={16} data-target={target} data-cursor="pointer" />}
      title={title}
      subtitle={<span className="dh-meta">{meta}</span>}
      pad={pad}
    />
  )
}

/** The day page: the same on the Mac and the iPhone. */
function Page({ s, phone }: { s: S; phone?: boolean }) {
  const tomorrow = s.day === 'tomorrow'
  const shown = tomorrow ? 4 : 6
  const doneCount = tomorrow ? 0 : s.done ? 2 : 1
  return (
    <div className="dh-page">
      <div className="dh-head">
        <div className="dh-dates">
          <div className="dh-kicker">
            <Roll>{tomorrow ? 'Tomorrow · Monday' : 'Today · Sunday'}</Roll>
          </div>
          <div className="dh-date">
            <Roll>{tomorrow ? '9 November' : '8 November'}</Roll>
          </div>
        </div>
        <div className="dh-nav">
          <span className="dh-today" data-show={tomorrow || undefined}>
            <Button size={phone ? 'large' : 'small'} data-target="today">Today</Button>
          </span>
          <span className="dh-arrow">
            <ChevronLeft size={18} strokeWidth={2} />
          </span>
          <span className="dh-arrow" data-target="next" data-cursor="pointer">
            <ChevronRight size={18} strokeWidth={2} />
          </span>
        </div>
      </div>

      <div className="dh-progress">
        <span className="dh-track">
          <span className="dh-fill" style={{ width: `${(doneCount / shown) * 100}%` }} />
        </span>
        <span className="dh-count">
          <Roll align="end">{`${doneCount} of ${shown} done`}</Roll>
        </span>
      </div>

      <div className="dh-list" data-crop>
        <Task
          title={<Text>Send Q4 hiring plan to leadership</Text>}
          meta={
            <>
              <Text>9:10 AM</Text>
              <Star size={11} className="dh-star" fill="currentColor" strokeWidth={0} />
              <Text>Meera</Text>
              <Age days={tomorrow ? 6 : 5} />
            </>
          }
        />
        <Collapse open={!(tomorrow && s.done)}>
          <Task
            title={<Text>Review Arjun's design doc</Text>}
            done={s.done}
            target="check-review"
            meta={
              <>
                <Text>2:30 PM</Text>
                <Age days={tomorrow ? 3 : 2} />
              </>
            }
          />
        </Collapse>
        <Collapse open={!tomorrow}>
          <Task
            title={<Text>Weekly status report</Text>}
            done
            meta={<Bar w={58} h={6} tone={2} />}
          />
        </Collapse>
        <Task
          title={<Text>Book the team offsite</Text>}
          meta={
            <>
              <Text>11:00 AM</Text>
              <Age days={tomorrow ? 2 : 1} />
            </>
          }
        />
        <Task title={<Bar w={150} h={7} tone={3} />} meta={<Bar w={48} h={6} tone={2} />} />
        <Task title={<Bar w={118} h={7} tone={3} />} meta={<Bar w={56} h={6} tone={2} />} />
      </div>
    </div>
  )
}

function Sidebar() {
  const items = [
    { icon: <CalendarDays size={16} strokeWidth={1.75} />, label: <Text>Today</Text>, selected: true },
    { icon: <NotebookText size={16} strokeWidth={1.75} />, label: <Bar w={46} h={7} tone={3} /> },
    { icon: <Library size={16} strokeWidth={1.75} />, label: <Bar w={38} h={7} tone={3} /> },
    { icon: <Users size={16} strokeWidth={1.75} />, label: <Bar w={44} h={7} tone={3} /> },
    { icon: <Search size={16} strokeWidth={1.75} />, label: <Bar w={40} h={7} tone={3} /> },
  ]
  // The Pages section under the tabs, as the Mac sidebar has it: filler.
  const pages = [52, 64, 44]
  return (
    <div className="dh-side">
      {items.map((it, i) => (
        <Row key={i} className="dh-side-row" lead={<span className="dh-side-icon">{it.icon}</span>} title={it.label} selected={it.selected} pad={8} />
      ))}
      <div className="dh-side-head"><Bar w={34} h={6} tone={2} /></div>
      {pages.map((w, i) => (
        <Row key={`p${i}`} className="dh-side-row" lead={<span className="dh-side-icon dh-side-icon--faint"><FileText size={16} strokeWidth={1.75} /></span>} title={<Bar w={w} h={7} tone={3} />} pad={8} />
      ))}
    </div>
  )
}

export function DayfoldHero() {
  // The phone design is touched, not clicked: the Stage switches to it below
  // 560px wide, so the cursor style follows the same width.
  const host = useRef<HTMLDivElement>(null)
  const [narrow, setNarrow] = useState(false)
  useLayoutEffect(() => {
    const el = host.current
    if (!el) return
    const ro = new ResizeObserver(([e]) => setNarrow(e.contentRect.width < 560))
    ro.observe(el)
    return () => ro.disconnect()
  }, [])
  return (
    <div ref={host}>
    <Stage<S>
      width={720}
      height={400}
      compact={{ below: 560, width: 358, height: 420 }}
      initial={initial}
      poster={POSTER}
      script={script}
      accent="#3B4A8C"
      cursor={{ at: REST, style: narrow ? 'touch' : 'real' }}
      className="dh"
    >
      {(s, _rect, layout) => {
        const reviews = s.day === 'tomorrow' || s.done ? '2' : '3'
        return layout === 'compact' ? (
          <>
            <Phone width={326} className="dh-phone">
              <div className="dh-app">
                <div className="dh-appbar">
                  <span className="dh-circle"><Settings size={20} strokeWidth={1.75} /></span>
                  <span className="dh-review"><Inbox size={18} strokeWidth={1.75} /><Roll>{reviews}</Roll></span>
                </div>
                <Page s={s} phone />
              </div>
            </Phone>
            <span data-target="rest" style={{ position: 'absolute', left: REST.compact.x, top: REST.compact.y }} />
          </>
        ) : (
          <>
            <Window
              className="dh-window"
              title="Dayfold"
              sidebar={<Sidebar />}
              sidebarWidth={168}
              toolbar={
                <span className="dh-review">
                  <Inbox size={16} strokeWidth={1.75} />
                  <Roll>{reviews}</Roll>
                </span>
              }
            >
              <Page s={s} />
            </Window>
            <span data-target="rest" style={{ position: 'absolute', left: REST.wide.x, top: REST.wide.y }} />
          </>
        )
      }}
    </Stage>
    </div>
  )
}
